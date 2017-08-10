defmodule Discordbot.Commands.Admin do
  @moduledoc """
  Commandes spécifiques pour l'administrateur du tchat
  """

  @limited_role 317371820296765441

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Tasks.Premium
  alias DiscordEx.RestClient
  alias Discordbot.Helpers.Message
  alias DiscordEx.Connections.REST

  @doc """
  Permet d'envoyer un message à travers le bot
  """
  def handle(:message_create, payload = %{"content" => "!all " <> message}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn -> Channel.send_message(conn, 85154866468487168, %{content: message}) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Nettoie plusieurs message à l'aide d'un bulk_delete
  !clean 10
  """
  def handle(:message_create, payload = %{"content" => "!clean " <> count, "channel_id" => channel_id}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn ->
        message_ids = conn
          |> Channel.messages(channel_id)
          |> Enum.map(&(&1["id"]))
          |> Enum.slice(0, String.to_integer(count) + 1)
        Channel.bulk_delete_messages(conn, channel_id, message_ids)
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Permet d'envoyer un message à travers le bot sur un channel spécifique
  ! #channel Message
  """
  def handle(:message_create, payload = %{"content" => "! <#" <> content}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      splits = String.split(content)
      message = splits |> Enum.drop(1) |> Enum.join(" ")
      channel_id = splits |> Enum.at(0) |> String.replace(">", "")
      spawn fn -> Channel.send_message(conn, channel_id, %{content: message})  end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Permet de changer le nom d'utilisateur du Bot
  !username <Username>
  """
  def handle(:message_create, payload = %{"content" => ("!username " <> username)}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn -> RestClient.resource(conn, :patch, "users/@me", %{username: username}) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Permet de changer l'avatar associé au bot
  !avatar <AvatarURLJPG>
  """
  def handle(:message_create, payload = %{"content" => ("!avatar " <> avatar_url)}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn ->
        {:ok, %{body: body}} = HTTPoison.get(avatar_url)
        RestClient.resource(conn, :patch, "users/@me", %{
          avatar: "data:image/jpeg;base64," <> :base64.encode(body)
        })
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Lance la mise à jour du système de premium
  !premium
  """
  def handle(:message_create, payload = %{"content" => "!premium"}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn -> Premium.update_role(:premium_process) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Permet de prévenir un utilisateur d'un comportement inapropié
  Exemple de Payload:
  %{
    "channel_id" => 261710699014146,
    "emoji" => %{"id" => nil, "name" => "⚠"},
    "message_id" => 339739827992599,
    "user_id" => 8515360760324096
  }
  """
  @spec handle(atom, map, map):: {atom, map}
  def handle(:message_reaction_add, payload = %{"channel_id" => channel_id, "emoji" => emoji, "message_id" => message_id, "user_id" => user_id}, state = %{rest_client: conn}) do
    quick_command = quick_command(emoji["name"])
    if is_mod?(user_id) && !is_nil(quick_command) do
      # On récupère le message original et on le supprime
      guild = Application.get_env(:discordbot, :guild)
      original_message = RestClient.resource(conn, :get, "channels/#{channel_id}/messages/#{message_id}")
      author_id = original_message["author"]["id"]
      # On supprime le message original
      Channel.delete_message(conn, channel_id, message_id)
      # On place l'utilisateur en limité
      spawn fn ->
        REST.put!("/guilds/#{guild}/members/#{author_id}/roles/#{@limited_role}", "", [
          {"Authorization", "Bot " <> Application.get_env(:discordbot, :api_key)},
          {"X-Audit-Log-Reason", URI.encode(Message.content_with_mentions(original_message))}
        ])
      end
      # On envoie un message sur le serveur privé
      %{"id" => message_id} = Channel.send_message(conn, 318532120458821633, %{content: """

        ```
        #{Message.content_with_mentions(original_message)}
        ```

        <@#{author_id}> #{quick_command.message}

        Vous pourrez reposter dans les autres channels dans #{quick_command.duration} minutes
        """}
      )
      Toniq.enqueue_with_delay(DiscordBot.UnmuteWorker, %{
        conn: conn,
        user: author_id,
        message: message_id
      }, delay_for: 1000 * quick_command.duration * 60)
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _data, state) do
    {:no, state}
  end

  @doc """
  Est-ce que le message viens bien de l'administrateur ?
  """
  def is_admin?(user_id) when is_integer(user_id), do: Application.get_env(:discordbot, :admin) == user_id
  def is_admin?(payload) when is_map(payload), do: Application.get_env(:discordbot, :admin) == payload["author"]["id"]

  def is_mod?(user_id) when is_integer(user_id) do
    :discordbot |> Application.get_env(:mods) |> Enum.member?(user_id)
  end

  def quick_command(%{"emoji" => %{"name" => name}}), do: quick_command(name)
  def quick_command(name) when is_binary(name) do
    quick_commands = Application.get_env(:discordbot, :quick_commands, %{})
    is_quick_command = quick_commands
      |> Map.keys()
      |> Enum.member?(name)
    if is_quick_command do
      Map.get(quick_commands, name, %{message: "", duration: 1})
    else
      nil
    end
  end

end

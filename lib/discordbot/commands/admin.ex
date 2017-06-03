defmodule Discordbot.Commands.Admin do
  @moduledoc """
  Commandes spécifiques pour l'administrateur du tchat
  """

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Tasks.Premium
  alias DiscordEx.RestClient

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
  Lance la mise à jour du système de premium
  !premium
  """
  def handle(:message_create, payload = %{"content" => "!test"}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      IO.inspect(conn)
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
  def is_admin?(payload) do
    Application.get_env(:discordbot, :admin) == payload["author"]["id"]
  end

end

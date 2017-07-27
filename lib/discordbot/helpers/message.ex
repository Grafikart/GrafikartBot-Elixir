defmodule Discordbot.Helpers.Message do
  @moduledoc """
  Série de fonction servant à "formater" les messages à envoyer
  """

  alias DiscordEx.RestClient.Resources.User
  alias DiscordEx.RestClient.Resources.Channel

  @doc """
  Permet d'envoyer un message à un utilisateur
  """
  def dm(conn, user_id, content) do
    case User.create_dm_channel(conn, user_id) do
      %{"id" => channel_id} -> Channel.send_message(conn, channel_id, %{content: content})
      map -> map
    end
  end

  @doc """
  Génère le code d'une mention utilisateur
  """
  def mention(%{"author" => %{"id" => user_id}}), do: mention(user_id)
  def mention(user_id), do: "<@#{user_id}>"

  @doc """
  Prepare un message replace @XXX with the right content
  """
  def prepare_message(template, %{"content" => content, "author" => %{"id" => user_id}}) do
    template
      |> String.replace("@user", mention(user_id))
      |> String.replace("@content", content)
  end

  @doc """
  Injecte les mentions dans un message
  """
  @spec content_with_mentions(map):: binary
  def content_with_mentions(%{"content" => content, "mentions" => mentions}) do
    Enum.reduce(mentions, content, fn(%{"id" => id, "username" => username}, message) ->
      String.replace(message, "<@#{id}>", "@#{username}")
    end)
  end

end

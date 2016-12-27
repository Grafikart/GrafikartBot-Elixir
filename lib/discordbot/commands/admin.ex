defmodule Discordbot.Commands.Admin do

  alias DiscordEx.RestClient.Resources.Channel

  @doc """
  Send a message on general channel
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
  Send a message to a specific channel
  ! #channel Message
  """
  def handle(:message_create, payload = %{"content" => "! <#" <> content}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      splits = String.split(content)
      message = Enum.drop(splits, 1) |> Enum.join(" ")
      channel_id = Enum.at(splits, 0) |> String.replace(">", "")
      spawn fn -> Channel.send_message(conn, channel_id, %{content: message})  end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Change bot username
  !username <Username>
  """
  def handle(:message_create, payload = %{"content" => ("!username " <> username)}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn -> DiscordEx.RestClient.resource(conn, :patch, "users/@me", %{username: username}) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  @doc """
  Change bot avatar
  !avatar <AvatarURLJPG>
  """
  def handle(:message_create, payload = %{"content" => ("!avatar " <> avatar_url)}, state = %{rest_client: conn}) do
    if is_admin?(payload) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn ->
        {:ok, %{body: body}} = HTTPoison.get(avatar_url)
        DiscordEx.RestClient.resource(conn, :patch, "users/@me", %{avatar: "data:image/jpeg;base64," <> :base64.encode(body)}) 
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _data, state) do
    {:no, state}
  end

  defp is_admin?(payload) do
    Application.get_env(:discordbot, :admin) == payload["author"]["id"]
  end

end
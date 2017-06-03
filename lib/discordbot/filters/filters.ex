defmodule Discordbot.Filters do

  @moduledoc """
  Filter the content of a channel to force a format on message
  """

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  def handle(:message_create, payload, state = %{rest_client: conn}) do
    case List.keyfind(Application.get_env(:discordbot, :filters), payload["channel_id"], 0) do
      {channel_id, filter} ->
        if Regex.run(filter, payload["content"]) do
          {:no, state}
        else
          spawn fn -> Channel.delete_message(conn, channel_id, payload["id"]) end
          spawn fn -> Message.dm(conn, payload["author"]["id"], message(payload)) end
          {:ok, state}
        end
      _ -> {:no, state}
    end
  end

  def handle(_type, _payload, state) do
    {:no, state}
  end

  def message(payload) do
    :discordbot
      |> Application.get_env(:filters_dm)
      |> String.replace("@content", payload["content"])
  end

end

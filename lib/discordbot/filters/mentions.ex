defmodule Discordbot.Filters.Mentions do
  @moduledoc """
  Filter and remove empty mentions (annoying as hell !)
  """

  alias DiscordEx.RestClient.Resources.Channel

  def handle(:message_create, payload = %{"content" => content, "channel_id" => channel_id}, state = %{rest_client: conn}) do
    if is_empty_mention?(content) do
      spawn fn -> 
        Channel.send_message(conn, channel_id, %{
          content: prepare_message(payload)
        }) 
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, payload, state) do
    {:no, state}
  end

  defp prepare_message(payload) do
    Application.get_env(:discordbot, :empty_mention)
      |> Discordbot.Helpers.Message.prepare_message(payload)
  end

  defp is_empty_mention?("<@" <> user_id) do
    Regex.run(~r/^([0-9]+)\>$/i, user_id) != nil
  end

  defp is_empty_mention?(_content) do
    false
  end

end
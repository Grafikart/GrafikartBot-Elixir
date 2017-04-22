# Permet de répondre "naturellement" lorsque le bot est mentionné
defmodule Discordbot.NaturalLanguage do

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  def handle(:message_create, payload = %{"content" => content, "channel_id" => channel_id, "author" => %{"id" => user_id}}, state) do
    mention = "<@" <> Integer.to_string(state.client_id) <> ">"
    if String.contains?(content, mention) do
      spawn fn ->
        {_, reply} = content |> String.replace(mention, "") |> Recast.reply()
        message = reply <> " " <> Message.mention(user_id)
        Channel.send_message(state[:rest_client], channel_id, %{content: message})
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _data, state) do
    {:no, state}
  end

end
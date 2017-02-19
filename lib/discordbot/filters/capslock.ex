defmodule Discordbot.Filters.Capslock do
  @moduledoc """
  Handle capslock message 
  """

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  def handle(:message_create, %{"content" => content, "channel_id" => channel_id, "author" => %{"id" => user_id}}, state) do
    if is_capslock(content) do
      message = Application.get_env(:discordbot, :capslock)
        |> String.replace("@user", Message.mention(user_id))
      spawn fn -> Channel.send_message(state[:rest_client], channel_id, %{content: message}) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _payload, state) do
    {:no, state}
  end

  def is_capslock(content) do
    content == String.upcase(content) and
    String.length(content) > 15 and
    Regex.match?(~r/[A-Z]{4,}/, content)
  end

end

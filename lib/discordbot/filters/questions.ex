defmodule Discordbot.Filters.Questions do
  @moduledoc """
  Handle questions "qqun connait ... ?"
  """

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  def handle(:message_create, %{"content" => content, "channel_id" => channel_id, "author" => %{"id" => user_id}}, state) do
    if is_question?(content) do
      message = Application.get_env(:discordbot, :question)
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

  @doc """
  Detect if the message is a question
  """
  @spec is_question?(String.t) :: boolean
  def is_question?(content) do
    if length(String.split(content)) <= 10 do
      Regex.run(~r/^(bonjour |salut )?(qui s'y conna(î|i)(t|s)|des gens|quelqu'un|qqun|des personnes)[^\?]+\?$/i, String.trim(content)) != nil
    else
      false  
    end
  end

end
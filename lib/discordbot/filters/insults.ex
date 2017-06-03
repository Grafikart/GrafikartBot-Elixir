defmodule Discordbot.Filters.Insults do
  @moduledoc """
  Filtre les insultes à partir d'un dinctionnaire et supprime les messages
  """

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  def handle(:message_create, payload, state = %{rest_client: conn}) do
    if is_insult?(payload["content"]) do
      spawn fn -> Channel.delete_message(conn, payload["channel_id"], payload["id"]) end
      spawn fn -> Message.dm(conn, payload["author"]["id"], dm(payload)) end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _payload, state) do
    {:no, state}
  end

  @doc """
  Detect if the message includes insults
  """
  @spec is_insult?(String.t) :: boolean
  def is_insult?(content) do
    insultes = Enum.join(Application.get_env(:discordbot, :insults)[:badwords], "|")
    Regex.run(~r/(\s(#{insultes})|(#{insultes})\s)$/i, content) != nil
  end

  @doc """
  Generate the message to send to the user
  """
  def dm(%{"content" => content}) do
    Application.get_env(:discordbot, :insults)[:dm]
      |> String.replace("@content", content)
  end

end

defmodule Discordbot.Filters.Error do

  @moduledoc """
  Find known errors and advise users accordingly
  """

  alias DiscordEx.RestClient.Resources.Channel

  def handle(:message_create, payload, state = %{rest_client: conn}) do
    case is_known_error?(payload["content"]) do
      {:ok, link} ->
        spawn fn -> Channel.send_message(conn, payload["channel_id"], %{content: message(link, payload)}) end
        {:ok, state}
      _ -> {:no, state}
    end
  end

  def handle(_type, _payload, state), do: {:no, state}

  @doc """
  Is the message contains a known error ?
  """
  def is_known_error?(msg) do
    Application.get_env(:discordbot, :errors)
      |> check_pattern(msg)
  end

  defp check_pattern([{pattern, link} | errors], msg) do
    case Regex.run(pattern, msg) do
      [_] -> {:ok, link}
      nil -> check_pattern(errors, msg)
    end
  end

  defp check_pattern([], _msg), do: :no

  defp message(link, payload) do
    template = ":mag_right: Hey je connais cette erreur @user ! N'hésite pas à regarder cette vidéo elle t'aidera à mieux comprendre de quoi il en retourne " <> link
    Discordbot.Helpers.Message.prepare_message(template, payload)
  end

end
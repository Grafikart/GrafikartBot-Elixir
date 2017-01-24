defmodule Discordbot.Commands.SMS do

  alias DiscordEx.RestClient.Resources.Channel

  @doc """
  Send a message on general channel
  """
  def handle(:message_create, payload = %{"content" => "!sms " <> _message}, state = %{rest_client: conn}) do
    Channel.delete_message(conn, payload["channel_id"], payload["id"])
    handle_sms(payload, state, __MODULE__)
  end

  def handle(_type, _data, state) do
    {:no, state}
  end

  def handle_sms(payload = %{"content" => "!sms " <> message}, state = %{rest_client: conn}, module) do
    if module.is_allowed(conn, payload) && !is_within_hour?(Map.get(state, :last_sms)) do
      module.send(message)
      {:ok, Map.put(state, :last_sms, :os.system_time(:seconds))}
    else
      {:no, state}
    end
  end

  defp is_within_hour?(nil) do false end
  defp is_within_hour?(time) do
    :os.system_time(:seconds) - time <= 3600
  end

  @doc """
  Send an SMS using mobile.free.fr
  """
  def send(message) do
    credentials = Application.get_env(:discordbot, :sms) |> Keyword.get(:credentials)
    HTTPoison.get("https://smsapi.free-mobile.fr/sendmsg", [], [params: Keyword.put(credentials, :msg, message)])
  end

  @doc """
  Does the user belongs to a role that can send SMS alerts ?
  """
  def is_allowed(conn, payload) do
    expected_role = Application.get_env(:discordbot, :sms) |> Keyword.get(:role)
    %{"guild_id" => guild_id} = Channel.get(conn, payload["channel_id"])
    %{"roles" => roles} = DiscordEx.RestClient.Resources.Guild.member(conn, guild_id, payload["author"]["id"])
    Enum.member?(roles, expected_role)
  end

end
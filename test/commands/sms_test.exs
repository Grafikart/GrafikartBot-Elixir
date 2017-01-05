defmodule SMSNotAllowedMock do
  def is_allowed(conn, payload) do
    false
  end
end

defmodule SMSAllowedMock do
  def is_allowed(conn, payload) do
    true
  end

  def send(message) do
  end
end

defmodule Discordbot.Commands.SMSTest do

  use ExUnit.Case, async: true

  alias Discordbot.Commands.SMS

  setup do
    {
      :ok,
      state: %{rest_client: self()},
      good_message: DiscordbotTest.message(%{"content" => "!sms Urgence !!"}),
      bad_message: DiscordbotTest.message(%{"content" => "aze Urgence !!"})
    }
  end

  test "user without access doesn't trigger SMS", %{state: state, good_message: message} do
    assert {:no, _} = SMS.handle_sms(message, state, SMSNotAllowedMock)
  end

  test "user with does trigger SMS", %{state: state, good_message: message} do
    assert {:ok, %{last_sms: last_sms}} = SMS.handle_sms(message, state, SMSAllowedMock)
    assert last_sms <= :os.system_time(:seconds)
  end

  test "SMS are delayed", %{state: state, good_message: message} do
    assert {:ok, state = %{last_sms: last_sms}} = SMS.handle_sms(message, state, SMSAllowedMock)
    assert {:no, %{last_sms: ^last_sms}} = SMS.handle_sms(message, state, SMSAllowedMock)
    assert {:ok, %{last_sms: _}} = SMS.handle_sms(message, Map.put(state, :last_sms, last_sms - 3700), SMSAllowedMock)
  end

end
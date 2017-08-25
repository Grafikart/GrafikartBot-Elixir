defmodule Discordbot.Filters.InsultsTest do

  use ExUnit.Case, async: true

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should detect insults" do
    message = "pute"
    assert Discordbot.Filters.Insults.is_insult?(message) == true
  end

  test "should detect absence of insults" do
    message = """
     scrollspy solutions, but has the following advantages:
     it is written on vanilla javascript,
    """
    assert Discordbot.Filters.Insults.is_insult?(message) == false
  end

  test "should delete the insult", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => "franchement c'est un truc de pute"
    })
    Discordbot.Filters.Insults.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, "users/@me/channels", _}}
  end

end

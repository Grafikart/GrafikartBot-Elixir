defmodule Discordbot.Filters.InsultsTest do

  use ExUnit.Case, async: true
  alias Discordbot.Filters.Insults

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should detect insults" do
    assert Insults.is_insult?("franchement c'est un truc de pute")
    assert Insults.is_insult?("pute")
  end

  test "should detect absence of insults" do
    message = """
     scrollspy solutions, but has the following advantages:
     it is written on vanilla javascript,
    """
    assert Insults.is_insult?(message) == false
    assert Insults.is_insult?("Voila le lien https://imgur.com/a/kfHpd") == false
  end

  test "should delete the insult", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => "franchement c'est un truc de pute"
    })
    Insults.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, "users/@me/channels", _}}
  end

end

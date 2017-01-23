defmodule Discordbot.Filters.MentionsTest do

  use ExUnit.Case, async: true

  doctest Discordbot.Filters.Mentions

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should warn if empty message", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "<@123123213>",
    })
    {:ok, _} = Discordbot.Filters.Mentions.handle(:message_create, message, state)
    assert_receive {_, _, {_, :post, _, _}}
  end

  test "do nothing otherwise", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "<@123123123> Hello world",
    })
    {:no, _} = Discordbot.Filters.Mentions.handle(:message_create, message, state)
    refute_receive {_, _, {_, :post, _, _}}
  end

end
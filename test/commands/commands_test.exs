defmodule Discordbot.CommandsTest do

  use ExUnit.Case, async: true

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "command is detected", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!demo <@123123213> Salut"
    })
    Discordbot.Commands.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, _, %{content: "demo <@123123213> - Salut"}}}
  end

  test "command alone is detected", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!demo"
    })
    assert {:ok, _} = Discordbot.Commands.handle(:message_create, message, state)
  end

  test "no commmand is not parsed", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!"
    })
    assert {:no, _} = Discordbot.Commands.handle(:message_create, message, state)
  end

  test "commands are throttled", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!demo <@123123213> Salut"
    })
    assert {:ok, state } = Discordbot.Commands.handle(:message_create, message, state)
    assert {:ok, _state } = Discordbot.Commands.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, _, %{content: "demo <@123123213> - Salut"}}}
    assert_receive {_, _, {_, :delete, _, _}}
    refute_receive {_, _, {_, :post, _, %{content: "demo <@123123213> - Salut"}}}
  end

  test "command is detected without user", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!demo Salut"
    })
    Discordbot.Commands.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, _, %{content: "demo  - Salut"}}}
  end

  test "command replace spaces by +", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!demo Salut les gens"
    })
    Discordbot.Commands.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, _, %{content: "demo  - Salut+les+gens"}}}
  end

  test "help command", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => "!help"
    })
    Discordbot.Commands.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}} # message is deleted
  end

end
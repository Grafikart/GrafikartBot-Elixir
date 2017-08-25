defmodule Discordbot.Commands.AdminTest do

  use ExUnit.Case, async: true

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "A non admin user can't use admin commands", %{state: state} do
    message = DiscordbotTest.message(%{
      "content"=> "!username bot",
    })
    Discordbot.Commands.Admin.handle(:message_create, message, state)
    refute_receive {_, _, {_, :delete, _, _}}
    refute_receive {_, _, {_, :patch, _, _}}
  end

  test "change username", %{state: state} do
    message = DiscordbotTest.message(%{
      "content"=> "!username bot",
      "author" => %{
        "id" => Application.get_env(:discordbot, :admin)
      }
    })
    Discordbot.Commands.Admin.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :patch, _, _}}
  end

  test "send all message", %{state: state} do
    message = DiscordbotTest.message(%{
      "content"=> "!all bot",
      "author" => %{
        "id" => Application.get_env(:discordbot, :admin)
      }
    })
    Discordbot.Commands.Admin.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, _, _}}
  end

  test "send a message to a specific channel", %{state: state} do
    message = DiscordbotTest.message(%{
      "content"=> "! <#1234> bot",
      "author" => %{
        "id" => Application.get_env(:discordbot, :admin)
      }
    })
    Discordbot.Commands.Admin.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
    assert_receive {_, _, {_, :post, "channels/1234/messages", _}}
  end

  test "get quick command" do
    reaction = %{
      "channel_id" => 261710699014146,
      "emoji" => %{"id" => nil, "name" => "patience"},
      "message_id" => 339739827992599,
      "user_id" => 8515360760324096
    }
    invalid_reaction = %{
      "channel_id" => 261710699014146,
      "emoji" => %{"id" => nil, "name" => "a"},
      "message_id" => 339739827992599,
      "user_id" => 8515360760324096
    }
    expected_message = Application.get_env(:discordbot, :quick_commands)["patience"].message
    assert %{duration: _, message: message} = Discordbot.Commands.Admin.quick_command(reaction)
    assert message == expected_message
    assert Discordbot.Commands.Admin.quick_command(invalid_reaction) == nil
  end


end

defmodule CapslockTest do

  use ExUnit.Case, async: true

  doctest Discordbot.Filters.Capslock

  alias Discordbot.Filters.Capslock

  setup do
    state = %{rest_client: self()}
    {:ok, 
      state: state,
      capslock_message: Application.get_env(:discordbot, :capslock) 
        |> String.replace("@user", "<@12345>")
    }
  end

  test "filter capsLock", %{state: state, capslock_message: capslock_message} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => "POURQUOI PERSONNE NE M'AIDE !"
    })
    Capslock.handle(:message_create, message, state)
    assert_receive {_, _, {_, _, _, %{content: ^capslock_message}}}
  end

  test "let mention pass", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => "<@123121231232133> ?"
    })
    assert {:no, _} = Capslock.handle(:message_create, message, state)
  end

  test "let short message pass", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => "$_SESSION"
    })
    Capslock.handle(:message_create, message, state)
    refute_receive {}
  end

end

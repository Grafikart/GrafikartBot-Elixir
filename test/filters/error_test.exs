defmodule Discordbot.Filters.ErrorTest do

  use ExUnit.Case, async: true

  @header_already_sent """
  yep sa dit que le soucis est ligne 46 mais que le problème commence ligne 43 Warning: Cannot modify header information - headers already sent by (output started at /Applications/MAMP/htdocs/header.php:43) in
  """
  @non_object "J'ai un problème avec l'erreur : Notice: Trying to get property of non-object in"

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should detect headers already sent" do
    assert {:ok, _msg} = Discordbot.Filters.Error.is_known_error?(@header_already_sent)
    assert {:ok, _msg} = Discordbot.Filters.Error.is_known_error?(@non_object)
  end

  test "should let pass if no errors" do
    assert :no = Discordbot.Filters.Error.is_known_error?("Hey how are you ?")
  end

  test "should send a message", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => @header_already_sent
    })
    Discordbot.Filters.Error.handle(:message_create, message, state)
    assert_receive {_, _, {_, :post, _, _}}
  end

end
ExUnit.start()

defmodule DiscordbotTest do

  def message do
    %{
      "attachments" => [],
      "author" => %{
        "avatar" => "e0d83e68a56b83c1e888fdc66fcd679a",
        "discriminator" => "1849", 
        "id" => 12345,
        "username" => "JohnDoe"
      }, 
      "channel_id" => 261641029042700288,
      "content" => "<@179599018270261248> Demo", 
      "edited_timestamp" => nil,
      "embeds" => [], 
      "id" => 261642928315826178, 
      "mention_everyone" => false,
      "mention_roles" => [],
      "mentions" => [%{
        "avatar" => "1c26a63b77e4f4ffc05f2467f0ee54f7",
        "bot" => true, 
        "discriminator" => "1521", 
        "id" => 179599018270261248,
        "username" => "!bot"
      }], 
      "nonce" => "261642927535554560",
      "pinned" => false, 
      "timestamp" => "2016-12-22T23:55:35.201000+00:00",
      "tts" => false, 
      "type" => 0
    }
  end

  def message(data) do
    Map.merge(message(), data)
  end

end

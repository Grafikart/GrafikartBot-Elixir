defmodule Discordbot.Helpers.Message.Test do

  use ExUnit.Case, async: true

  @message_with_mentions %{"attachments" => [],
  "author" => %{"avatar" => "dbe9af8ae5a4038d243a4da2c29ab4de",
  "discriminator" => "1849", "id" => "85153608760324096",
  "username" => "Grafikart"}, "channel_id" => "261792010699014146",
  "content" => "<@86952681251307520> met un warning sur celui là",
  "edited_timestamp" => nil, "embeds" => [], "id" => "339800840862957568",
  "mention_everyone" => false, "mention_roles" => [],
  "mentions" => [%{"avatar" => "30ed3f5ae4dc8adef99bafeef4df5523",
  "discriminator" => "6172", "id" => "86952681251307520",
  "username" => "Renouveaux"}], "pinned" => false,
  "reactions" => [%{"count" => 1, "emoji" => %{"id" => nil, "name" => "⚠"},
  "me" => false}], "timestamp" => "2017-07-26T16:07:13.656000+00:00",
  "tts" => false, "type" => 0}


  @message_without_mention %{"attachments" => [],
  "author" => %{"avatar" => "dbe9af8ae5a4038d243a4da2c29ab4de",
  "discriminator" => "1849", "id" => "85153608760324096",
  "username" => "Grafikart"}, "channel_id" => "261792010699014146",
  "content" => "met un warning sur celui là",
  "edited_timestamp" => nil, "embeds" => [], "id" =>  "339800840862957568",
  "mention_everyone" => false, "mention_roles" => [],
  "mentions" => [%{"avatar" => "30ed3f5ae4dc8adef99bafeef4df5523",
  "discriminator" => "6172", "id" => "86952681251307520",
  "username" => "Renouveaux"}], "pinned" => false,
  "reactions" => [%{"count" => 1, "emoji" => %{"id" => nil, "name" => "⚠"},
  "me" => false}], "timestamp" => "2017-07-26T16:07:13.656000+00:00",
  "tts" => false, "type" => 0}

  test "It should parse message correctly when no mentions" do
    assert "met un warning sur celui là" == Discordbot.Helpers.Message.content_with_mentions(@message_without_mention)
  end

  test "It should parse message correctly when mentions" do
    assert "@Renouveaux met un warning sur celui là" == Discordbot.Helpers.Message.content_with_mentions(@message_with_mentions)
  end

end

defmodule Recast.Test do

  use ExUnit.Case, async: true

  @intent %{"message" => "Converses rendered with success",
         "results" => %{
           "action" =>  %{"done" => true, "reply" => "123456", "slug" => "want-drink"},
           "conversation_token" => "XXXXXXXX",
           "entities" => %{"number" => [%{"confidence" => 0.99, "raw" => "une", "scalar" => 1}]},
           "intents" => [%{"confidence" => 0.99, "slug" => "want-drink"}],
           "language" => "fr", "memory" => %{}, "next_actions" => [],
           "processing_language" => "fr",
           "replies" => ["123456"],
           "sentiment" => "neutral",
           "source" => "On se boit une bière ?", "status" => 200,
           "timestamp" => "2017-04-22T14:39:59.975367+00:00",
           "uuid" => "XXXXXXXX",
           "version" => "2.6.0"}}
  @nointent %{"message" => "Converses rendered with success",
   "results" => %{"action" => nil,
     "conversation_token" => "XXXXXXXX",
     "entities" => %{"pronoun" => [%{"confidence" => 0.84,
          "gender" => "unknown", "number" => "singular",
          "person" => 1, "raw" => "Je"}]}, "intents" => [],
     "language" => "fr", "memory" => %{}, "next_actions" => [],
     "processing_language" => "fr",
     "replies" => ["what ?"],
     "sentiment" => "neutral",
     "source" => "Je vais tondre le gazon", "status" => 200,
     "timestamp" => "2017-04-22T14:40:29.460384+00:00",
     "uuid" => "XXXXXXXX",
     "version" => "2.6.0"}}

  test "reply with the correct answer" do
    assert "what ?" == Recast.reply(@nointent)
    assert "123456" == Recast.reply(@intent)
  end

  test "intent is detected" do
    assert false == Recast.intent(@nointent)
    assert "want-drink" == Recast.intent(@intent)
  end

end
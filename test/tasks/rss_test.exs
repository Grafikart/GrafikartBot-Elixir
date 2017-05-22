defmodule Discordbot.Tasks.RSS.Test do

  use ExUnit.Case, async: true
  alias Discordbot.Tasks.RSS

  def fake_rss do
    {:ok, body} = File.read("test/tasks/fake.rss")
    body
  end

  def fake_entry do
    %{
      title: "Tutoriel Laravel : Laravel Echo",
      link: "https://www.grafikart.fr/tutoriels/laravel/laravel-echo-websocket-890"
    }
  end

  test "Get last post" do
    last_post = RSS.last_post(fake_rss())
    assert last_post = fake_entry()
  end

  test "Format message" do
    assert "**<:grafikart:250692379638497280> Nouveau Tutoriel Laravel ** : Laravel Echo https://www.grafikart.fr/tutoriels/laravel/laravel-echo-websocket-890" = RSS.get_message(fake_entry())
  end

end
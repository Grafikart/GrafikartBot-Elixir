use Mix.Config

config :toniq, redis_url: "redis://127.0.0.1:6379/0"

config :discordbot,
  test: true,
  admin: 100,
  filters: [
    {200, ~r/^(\[[^\]]+\]|<\:[a-z0-9]+\:[0-9]+>) .+ https?:\/\/\S*$/}
  ],
  commands: [
    demo: "demo @user - @content"
  ]
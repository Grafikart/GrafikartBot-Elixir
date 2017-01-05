use Mix.Config

config :discordbot,
  admin: 123123123, # Who can execute admin commands
  api_key: "YOUR API KEY HERE", # API key to access discord API
  # Force a message pattern inside a channel
  filters: [
    # {channel_id, regex}
    {123, ~r/^(\[[^\]]+\]|<\:[a-z0-9]+\:[0-9]+>) .+ https?:\/\/\S*$/}
  ],
  sms: [
    role: "ROLE ID",
    credentials: [
      pass: "FREEBOX PASS",
      user: "FREEBOX USER"
    ]
  ]
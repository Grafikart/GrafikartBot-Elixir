defmodule Discordbot do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    api_key = Application.get_env(:discordbot, :api_key)
    children = if api_key do
      [
        worker(Discordbot.Bot, [api_key], modules: [Discordbot.Botserver]),
        worker(Discordbot.Tasks.Premium, [:premium_process]),
        worker(Discordbot.Tasks.Autoprune, [api_key, Application.get_env(:discordbot, :guild)])
      ]
    else
      []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Discordbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

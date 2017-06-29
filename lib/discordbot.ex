defmodule Discordbot do
  @moduledoc """
  Superviseur permettant la gestion du bot
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    api_key = Application.get_env(:discordbot, :api_key)
    children = if api_key do
      [
        # Le bot
        worker(Discordbot.Bot, [api_key], modules: [Discordbot.Botserver]),
        # Vérifie les nouveaux premiums
        worker(Discordbot.Tasks.Premium, [:premium_process]),
        # Auto prune les utilisateur au bout de X jours
        # worker(Discordbot.Tasks.Autoprune, [api_key, Application.get_env(:discordbot, :guild)]),
        # Parse le flux RSS à la recherche de nouvelles vidéos
        worker(Discordbot.Tasks.RSS, [api_key, Application.get_env(:discordbot, :guild)])
      ]
    else
      []
    end

    opts = [strategy: :one_for_one, name: Discordbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

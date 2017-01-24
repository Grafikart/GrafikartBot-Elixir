defmodule Discordbot.Tasks.Autoprune do
  @moduledoc """
  GenServer permettant de mettre à jour les utilisateurs premiums depuis le site
  """

  use GenServer

  alias DiscordEx.RestClient.Resources.Guild

  @period 60 * 1000

  ####
  # Client
  ####
  def start_link(api_key, guild) do
    GenServer.start_link(__MODULE__, %{
      rest_client: nil,
      api_key: api_key,
      guild: guild
    })
  end

  def init(state) do
    {:ok, conn} = DiscordEx.RestClient.start_link(%{token: "Bot " <> state.api_key})
    schedule_work()
    {:ok, Map.put(state, :rest_client, conn)}
  end

  @doc """
  Prune all users
  """
  def prune(pid) do
    GenServer.cast(pid, :prune)
  end

  # Relance le process toutes les X secondes
  defp schedule_work do
    Process.send_after(self(), :prune, @period) 
  end

  def handle_info(:prune, state) do
    schedule_work()
    IO.inspect("I'm pruning")
    Guild.begin_prune(state.rest_client, state.guild, %{days: 3})
    {:noreply, state}
  end

end
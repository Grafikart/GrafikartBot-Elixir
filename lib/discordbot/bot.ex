defmodule Discordbot.Bot do
  @moduledoc """
  GenServer contrôlant le bot
  """

  require Logger

  alias DiscordEx.Client

  @doc """
  Démarre le processus
  """
  def start_link(api_key) do
    Logger.debug "Starting bot..."
    Client.start_link(%{
      token: api_key,
      handler: __MODULE__
    })
  end

  @doc """
  Gère l'évènement reçu par le bot en le passant à travers différents modules
  """
  def handle_event({type, %{data: data}}, state) do
    if data["author"]["id"] != state.client_id do
      perform_handles(type, data, state, [
        # Discordbot.NaturalLanguage,
        Discordbot.Filters.Insults,
        Discordbot.Filters.Questions,
        Discordbot.Filters.Capslock,
        Discordbot.Filters.Code,
        Discordbot.Filters.Mentions,
        Discordbot.Filters.Error,
        Discordbot.Filters,
        Discordbot.Commands,
        Discordbot.Commands.SMS,
        Discordbot.Commands.Role,
        Discordbot.Commands.Admin,
        Discordbot.Commands.Benevolat
      ])
    else
      {:ok, state}
    end
  end

  @doc """
  L'évènement n'est pas reconnu, on ne fait rien
  """
  def handle_event({_type, _payload}, state) do
    {:ok, state}
  end

  defp perform_handles(_type, _data, state, []), do: {:ok, state}
  defp perform_handles(type, data, state, [module | remaining_modules]) do
    case :erlang.apply(module, :handle, [type, data, state]) do
      {:no, state} -> perform_handles(type, data, state, remaining_modules)
      {:ok, state} -> {:ok, state}
    end
  end

end

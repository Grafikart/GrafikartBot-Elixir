defmodule Discordbot.Bot do

  ## Client API
  def start_link(api_key) do
    IO.puts "Starting bot"
    DiscordEx.Client.start_link(%{
      token: api_key,
      handler: __MODULE__
    })
  end

  ## Server API
  def handle_event({type, %{data: data}}, state) do
    if data["author"]["id"] != state.client_id do
      perform_handles(type, data, state, [
        Discordbot.Capslock,
        Discordbot.Code,
        Discordbot.Ping,
        Discordbot.Filters,
        Discordbot.Filters.Insults,
        Discordbot.Commands,
        Discordbot.Commands.SMS,
        Discordbot.Commands.Admin
      ])
    else
      {:ok, state}
    end
  end

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
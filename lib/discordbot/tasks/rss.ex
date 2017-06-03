defmodule Discordbot.Tasks.RSS do
  @moduledoc """
  Parse un flux RSS et annonce les nouveaux tutoriels
  """

  use GenServer

  alias DiscordEx.RestClient.Resources.Guild
  alias DiscordEx.RestClient.Resources.Channel
  alias DiscordEx.RestClient
  alias HTTPoison.Response

  @period 2 * 60 * 1000

  ####
  # Client
  ####
  def start_link(api_key, guild) do
    GenServer.start_link(__MODULE__, %{
      rest_client: nil,
      last_post: nil,
      api_key: api_key,
      guild: guild
    })
  end

  def init(state) do
    {:ok, conn} = RestClient.start_link(%{token: "Bot " <> state.api_key})
    schedule_work()
    new_state = state
      |> Map.put(:rest_client, conn)
      |> Map.put(:last_post, last_post())
    {:ok, new_state}
  end

  ####
  # Server
  ####
  # Relance le process toutes les X secondes
  defp schedule_work do
    Process.send_after(self(), :parse_rss, @period)
  end

  def handle_info(:parse_rss, state) do
    schedule_work()
    last_post = last_post()
    if state.last_post != last_post && last_post != nil do
      Channel.send_message(state.rest_client, default_channel(state), %{
        content: get_message(last_post)
      })
      {:noreply, Map.put(state, :last_post, last_post)}
    else
      {:noreply, state}
    end
  end

  @doc """
  Permet d'obtenir le chan principal sur discord'
  """
  def default_channel(%{rest_client: rest_client, guild: guild}) do
    rest_client
      |> Guild.get(guild)
      |> Map.get("embed_channel_id")
  end

  @doc """
  Formate le message d'annonce d'un nouveau tutoriel
  """
  def get_message(%{title: title, link: link}) do
    parts = String.split(title, ":", parts: 2)
    markdown_title =
      "**<:grafikart:250692379638497280> Nouveau " <>
      Enum.fetch!(parts, 0) <>
      ":**" <>
      Enum.fetch!(parts, 1)
    markdown_title <> " " <> link
  end

  @doc """
  Permet de récupérer le dernier article depuis le flux RSS
  """
  def last_post do
    rss_feed = Application.get_env(:discordbot, :rss)
    case HTTPoison.get(rss_feed) do
      {:ok, %Response{body: body}} -> last_post(body)
      _ -> nil
    end
  end

  def last_post(body) when is_binary(body) do
    case FeederEx.parse(body) do
      {:ok, feed, _} -> List.first(feed.entries)
      _ -> nil
    end

  end

end

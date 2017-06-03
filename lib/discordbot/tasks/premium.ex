
defmodule Discordbot.Tasks.Premium do
  @moduledoc """
  GenServer permettant de mettre à jour les utilisateurs premiums depuis le site
  """

  use GenServer

  alias DiscordEx.RestClient.Resources.Guild
  alias DiscordEx.RestClient

  @period 600 * 1000
  @users_per_calls 1000

  ####
  # Client
  ####

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{
      premiums: [],                                           # Premiums users registered
      role: Application.get_env(:discordbot, :premium_role),  # Premium role ID
      guild: Application.get_env(:discordbot, :guild)         # Guild ID
    }, name: name)
  end

  def init(state) do
    {:ok, conn} = RestClient.start_link(%{token: "Bot " <> Application.get_env(:discordbot, :api_key)})
    # On récupère tous les utilisateurs premiums
    premiums = get_premiums(conn, state.guild, state.role)
    schedule_work()
    {:ok, Map.merge(state, %{
      rest_client: conn,
      premiums: premiums
    })}
  end

  @doc """
  Met à jour le rôle premium avec les utilisateurs premium depuis la base de donnée
  """
  def update_role(pid) do
    GenServer.cast(pid, :update_role)
  end

  # Relance le process toutes les X secondes
  defp schedule_work do
    Process.send_after(self(), :update_role, @period) # In 2 hours
  end

  # Récupère la liste de tous les utilisateurs dans le role premium du channel
  defp get_premiums(conn, guild, premium_role) do
    conn
      |> get_members(guild, 0)
      |> Enum.filter(fn (user) -> Enum.member?(user["roles"], premium_role) end)
      |> Enum.map(&(&1["user"]["id"]))
  end

  # Récupère tous les membres d'un Guild récusrivement
  defp get_members(conn, guild, last_member) do
    members = Guild.members(conn, guild, %{limit: @users_per_calls, after: last_member})
    if length(members) === @users_per_calls do
      Enum.concat(members, get_members(conn, guild, List.last(members)["user"]["id"]))
    else
      members
    end
  end

  ####
  # Server
  ####

  def handle_cast(:update_role, state) do
    handle_update_role(state)
  end

  def handle_info(:update_role, state) do
    schedule_work()
    handle_update_role(state)
  end

  defp handle_update_role(state) do
    premiums = get_premium_ids()
    new_premiums = (premiums -- state.premiums) |> Enum.map(&(add_premium(&1, state)))
    removed_premium = (state.premiums -- premiums) |> Enum.map(&(remove_premium(&1, state)))
    {:noreply, Map.put(state, :premiums, (state.premiums ++ new_premiums) -- removed_premium)}
  end

  # Permet de passer un utilisateur premium sur Discord
  @spec add_premium(String.t, map) :: String.t
  defp add_premium(user_id, %{guild: guild, role: role, rest_client: conn}) do
    RestClient.resource(conn, :put, "guilds/#{guild}/members/#{user_id}/roles/#{role}")
    user_id
  end

  # Permet de supprimer un utilisateur premium sur Discord
  @spec remove_premium(String.t, map) :: String.t
  defp remove_premium(user_id, %{guild: guild, role: role, rest_client: conn}) do
    RestClient.resource(conn, :delete, "guilds/#{guild}/members/#{user_id}/roles/#{role}")
    user_id
  end

  # Permet de récupérer les IDs Discord des membres premium
  # ["123","123124","123124"]
  defp get_premium_ids do
    {:ok, p} = Mariaex.start_link(Application.get_env(:discordbot, :database))
    {:ok, results} = Mariaex.query(p, "SELECT discord_id FROM users WHERE discord_id IS NOT NULL AND premium >= NOW()")
    results.rows |> Enum.map(fn(x) -> List.first(x) end)
  end

end

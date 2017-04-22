defmodule Discordbot.Commands.Role do

  alias DiscordEx.RestClient.Resources.Guild
  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Helpers.Message

  @doc """
  Affiche les différents rôles
  """
  def handle(:message_create, payload = %{"content" => "!roles"}, state), do: list_roles(payload, state)
  def handle(:message_create, payload = %{"content" => "!role"}, state), do: list_roles(payload, state)

  @doc """
  Permet de se placer dans un role particulier
  """
  def handle(:message_create, payload = %{"content" => "!role " <> role, "author" => %{"id" => user_id}}, state = %{rest_client: conn}) do
    roles = Application.get_env(:discordbot, :roles)
    guild_id = Application.get_env(:discordbot, :guild)
    spawn fn ->
      message = case Map.get(roles, role) do
        nil -> "Je ne connais pas ce rôle :( "
        role_id ->
          DiscordEx.RestClient.resource(conn, :put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}")
          "Tu es " <> role <> " maintenant"
      end
      Channel.send_message(conn, payload["channel_id"], %{content: message <> " " <> Message.mention(user_id)})
    end
    {:ok, state}
  end

  @doc """
  Permet de se retirer d'un role particulier
  """
  def handle(:message_create, payload = %{"content" => "!rmrole " <> role, "author" => %{"id" => user_id}}, state = %{rest_client: conn}) do
    roles = Application.get_env(:discordbot, :roles)
    guild_id = Application.get_env(:discordbot, :guild)
    spawn fn ->
      message = case Map.get(roles, role) do
        nil -> "Je ne connais pas ce rôle :( "
        role_id ->
          DiscordEx.RestClient.resource(conn, :delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}")
          "Tu n'es plus " <> role <> " maintenant"
      end
      Channel.send_message(conn, payload["channel_id"], %{content: message <> " " <> Message.mention(user_id)})
    end
    {:ok, state}
  end

  defp list_roles(payload, state = %{rest_client: conn}) do
    spawn fn ->
      Channel.delete_message(conn, payload["channel_id"], payload["id"])
      Channel.send_message(conn, payload["channel_id"], %{content: "Voici la liste des rôles : " <> roles_str()})
    end
    {:ok, state}
  end

  def handle(_type, _data, state), do: {:no, state}

  def roles(), do: Application.get_env(:discordbot, :roles)

  def roles_str() do
    roles()
      |> Map.keys()
      |> Enum.join(", ")
  end

end
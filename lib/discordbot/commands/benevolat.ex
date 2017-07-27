defmodule Discordbot.Commands.Benevolat do
  @moduledoc """
  Permet de gérer l'accès au channel bénévolat
  """

  @role_id 332449208940363777
  @message_leave 332460178127716352
  @source_channel 332454184450260992
  @dest_channel 332455285832679428

  alias DiscordEx.RestClient.Resources.Channel
  alias Discordbot.Tasks.Premium
  alias DiscordEx.RestClient

  @doc """
  Permet d
  """
  def handle(
    :message_reaction_add,
    payload = %{"user_id" => user_id, "channel_id" => channel_id, "message_id" => message_id},
    state = %{rest_client: conn}
  ) do
    guild_id = Application.get_env(:discordbot, :guild)
    cond do
      channel_id == @source_channel ->
        RestClient.resource(conn, :put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{@role_id}")
        {:ok, state}
      message_id == 332460178127716352 ->
        RestClient.resource(conn, :delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{@role_id}")
        {:ok, state}
      true -> {:no, state}
    end
  end

  @doc """
  Permet d'envoyer un message à travers le bot
  """
  def handle(:message_reaction_remove, payload, state) do
    handle(:message_reaction_add, payload, state)
  end

  def handle(_type, _data, state) do
    {:no, state}
  end

end

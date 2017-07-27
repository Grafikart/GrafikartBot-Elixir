defmodule DiscordBot.UnmuteWorker do
  @moduledoc """
  Demute les gens après les avoir placé dans le salon limité
  """

  @limited_role 317371820296765441
  @limited_channel 318532120458821633

  use Toniq.Worker

  alias DiscordEx.RestClient.Resources.Channel
  alias DiscordEx.RestClient

  def perform(%{conn: conn, user: user, message: message}) do
    guild = Application.get_env(:discordbot, :guild)
    Channel.delete_message(conn, @limited_channel, message)
    RestClient.resource(conn, :delete, "guilds/#{guild}/members/#{user}/roles/#{@limited_role}")
  end

end

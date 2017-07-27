defmodule Discordbot.Filters.Chocopain do
  @moduledoc """
  Evite les conflits liés à l'appellation de cette patisserie
  """

  alias DiscordEx.RestClient.Resources.Channel

  def handle(:message_create, payload, state = %{rest_client: conn}) do
    if is_chocopain?(payload["content"]) do
      spawn fn -> 
        Channel.send_message(conn, payload["channel_id"], %{
          content: ":croissant: Afin d'éviter tout débat merci d'utiliser le mot consacré **chocopain** pour désigner cette patisserie"
        })
      end
      {:ok, state}
    else
      {:no, state}
    end
  end

  def handle(_type, _payload, state) do
    {:no, state}
  end

  @doc """
  Permet de détecter si un message concerne les chocopains
  
  ## Exemples

    iex> Discordbot.Filters.Chocopain.is_chocopain?("Ce matin j'ai mangé un pain au chocolat il était délicieux")
    true

    iex> Discordbot.Filters.Chocopain.is_chocopain?(%{"content" => "J'aime les chocolatines au chocolat !"})
    true

    iex> Discordbot.Filters.Chocopain.is_chocopain?("J'aime les chocopains")
    false
  """
  @spec is_chocopain?(String.t):: boolean
  def is_chocopain?(content) when is_binary(content) do
    Regex.run(~r/pain au chocolat|chocolatine/i, content) != nil
  end
  def is_chocopain?(%{"content" => content}), do: is_chocopain?(content)

end

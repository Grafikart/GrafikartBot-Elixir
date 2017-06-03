defmodule Hastebin do
  @moduledoc """
  Envoie le code sur hastebin et renvoie le lien
  """

  @doc """
  Envoie le code sur hastebin et renvoie le lien
  """
  @spec send(String.t) :: {:ok | :ko, String.t}
  def send(data) do
    case HTTPoison.post "https://hastebin.com/documents", data, [{"Content-Type", "application/json"}] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"key" => key} = Poison.decode!(body)
        {:ok, "https://hastebin.com/" <> key}
      _ -> {:ko, "Not found :("}
    end
  end

end

defmodule Recast do

  def reply(message) when is_binary(message) do
    data = Poison.encode!(%{text: message, language: "fr"})
    headers = %{
      "Content-Type" => "application/json",
      "Authorization"=> token()
    }
    case HTTPoison.post("https://api.recast.ai/v2/converse", data, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        reply = body
           |> Poison.decode!()
           |> reply()
        {:ok, reply}
      _ ->
        {:ko, config().api_down}
    end
  end

  @doc """
  Get the reply from recast payload
  """
  def reply(%{"results" => %{"replies" => replies}}), do: Enum.random(replies)
  def reply(_), do: config().no_intent

  @doc """
  Get intent slug from recast payload
  """
  def intent(%{"results" => %{"action" => %{"slug" => slug}}}), do: slug
  def intent(_), do: false

  def token() do
    "Token " <> config().token
  end

  def config() do
   Application.get_env(:discordbot, :recast)
  end

end
defmodule OwnYourPlaylist.Streamer.Spotify.Account do
  @moduledoc """
  Interacts with the Spotify Account API to receive authentication tokens
  to read data.
  """
  import OwnYourPlaylist.Util.TeslaResponse
  alias OwnYourPlaylist.Util.Config

  @doc """
  Returns a general Application specific Access Token and it's expiry time in
  seconds.
  This token is NOT specific to any user, so only public resources can be
  requested using it.
  """
  def auth_token() do
    client()
    |> Tesla.post("/api/token", %{grant_type: "client_credentials"})
    |> handle_response()
    |> parse_result()
  end

  defp parse_result({:ok, result}) do
    {:ok, Map.fetch!(result, "access_token"), Map.fetch!(result, "expires_in")}
  end
  defp parse_result(other), do: other

  defp client() do
    [
      {Tesla.Middleware.BaseUrl, "https://accounts.spotify.com"},
      {
        Tesla.Middleware.BasicAuth,
        username: Config.read!(__MODULE__, :client_id),
        password: Config.read!(__MODULE__, :client_secret)
      },
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end
end

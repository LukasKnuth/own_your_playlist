defmodule OwnYourPlaylist.External.Spotify do
  @moduledoc "Top-level module for interacting with Spotify Web API"

  require Logger

  @otp_app :own_your_playlist

  def fetch_token() do
    [
      {Tesla.Middleware.BaseUrl, "https://accounts.spotify.com"},
      {
        Tesla.Middleware.BasicAuth,
        username: read_config!(:client_id),
        password: read_config!(:client_secret)
      },
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
    |> Tesla.post("/api/token", %{grant_type: "client_credentials"})
    |> handle_response()
  end

  defp api_client(opts) do
    [
      {Tesla.Middleware.Retry, delay: 2, max_retries: 10, max_delay: 128},
      # TODO opentelemetry middleware?
      {Tesla.Middleware.BaseUrl, "https://api.spotify.com"},
      {Tesla.Middleware.BearerAuth, token: Keyword.fetch!(opts, :token)},
      {Tesla.Middleware.BaseUrl, Keyword.fetch!(opts, :base_url)},
      Tesla.Middleware.PathParams,
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status >= 200 and status < 300 do
    {:ok, body}
  end
  defp handle_response({:ok, %{status: status, body: body}}) do
    Logger.error("Spotify response indicates error", status: status, body: body)
    
    {:error, {:status, status}}
  end
  defp handle_response({:error, _} = err) do
    Logger.error("Unhandled error in Spotify client", error: err)

    err
  end

  defp read_config!(key) do
    @otp_app
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(key)
  end
end

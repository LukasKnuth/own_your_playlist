defmodule OwnYourPlaylist.Streamer.Spotify do
  @moduledoc "Top-level module for interacting with Spotify Web API"

  require Logger

  alias OwnYourPlaylist.Models.{Playlist, Track}

  @otp_app :own_your_playlist

  def playlist(token, id) do
    [token: token]
    |> api_client()
    # TODO use "fields" option to reduce payload size
    |> Tesla.get("/v1/playlists/{id}", opts: [path_params: [id: id]])
    |> handle_response()
    |> parse_playlist()
  end

  defp parse_playlist({:ok, response}) do
    tracks =
      response
      |> get_in(["tracks", "items"])
      # TODO just filter `is_local` tracks here? Or show in UI?
      |> Enum.map(&parse_track/1)

    %Playlist{
      id: Map.fetch!(response, "id"),
      external_url: get_in(response, ["external_urls", "spotify"]),
      name: Map.get(response, "name"),
      owner: get_in(response, ["owner", "display_name"]),
      tracks: tracks
    }
  end
  defp parse_playlist(other), do: other

  def parse_track(item) do
    %Track{
      album_name: get_in(item, ["track", "album", "name"]),
      artist_names: get_in(item, ["track", "artists", Access.all(), "name"]),
      name: get_in(item, ["track", "name"])
    }
  end

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

defmodule OwnYourPlaylist.Streamer.Spotify.Api do
  @moduledoc """
  Interacts with the Spotify API using a previously obtained Access Token.
  """
  import OwnYourPlaylist.Util.TeslaResponse
  alias OwnYourPlaylist.Models.{Playlist, Track}
  
  @doc """
  Fetches a Playlist from Spotify using it's playlist ID.
  The given token must be allowed to read the playlist! If the playlist is
  public, an Application wide token will suffice. For private playlists, a
  user specific token must be used.
  """
  def fetch_playlist(token, id) do
    [token: token]
    |> client()
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

  defp parse_track(item) do
    %Track{
      album_name: get_in(item, ["track", "album", "name"]),
      artist_names: get_in(item, ["track", "artists", Access.all(), "name"]),
      name: get_in(item, ["track", "name"])
    }
  end

  defp client(opts) do
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
end

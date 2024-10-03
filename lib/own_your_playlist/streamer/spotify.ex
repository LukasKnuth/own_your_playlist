defmodule OwnYourPlaylist.Streamer.Spotify do
  @moduledoc "Top-level module for interacting with Spotify Web API"
  @link_host "open.spotify.com"
  
  defdelegate auth_token(), to: __MODULE__.Account
  defdelegate fetch_playlist(token, id), to: __MODULE__.Api

  def id_from_link(link) do
    case URI.parse(link) do
      %URI{host: @link_host, path: "/playlist/" <> id} -> {:ok, id}
      %URI{host: @link_host, path: path} -> {:error, {:not_a_playlist, path}}
      %URI{host: host} -> {:error, {:unsupported_service, host}}
    end
  end
end

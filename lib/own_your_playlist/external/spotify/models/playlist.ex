defmodule OwnYourPlaylist.External.Spotify.Models.Playlist do
  @enforce_keys [:name, :owner, :tracks]
	defstruct [
	  :name,
	  :owner,
	  :tracks,
	  :spotify_url
	]
end

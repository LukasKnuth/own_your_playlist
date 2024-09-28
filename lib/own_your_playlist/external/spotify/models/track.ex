defmodule OwnYourPlaylist.External.Spotify.Models.Track do
	@moduledoc "A single track on Spotify"
	@enforce_keys [:album_name, :artist_names, :name]
	defstruct [
	  :album_name,
	  :artist_names,
	  :name,
	  is_local: false
	]
end

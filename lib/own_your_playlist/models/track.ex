defmodule OwnYourPlaylist.Models.Track do
  @moduledoc """
  A single track from a Playlist.
  """

	@enforce_keys [:album_name, :artist_names, :name]
	defstruct [
	  :album_name,
	  :artist_names,
	  :name,
	]
end

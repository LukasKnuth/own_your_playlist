defmodule OwnYourPlaylist.Models.Playlist do
  @moduledoc """
  A playlist containing songs, possibly from different artists/albums.
  """

  @enforce_keys [:id, :name, :owner, :tracks]
	defstruct [
	  :id,
	  :name,
	  :owner,
	  :tracks,
	  :external_url
	]
end

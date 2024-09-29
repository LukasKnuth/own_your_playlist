defmodule OwnYourPlaylist.Models.Result do
  @moduledoc """
  A single purchasable result from any Music Catalogue.
  # TODO Refactor name and folder
  """

  @enforce_keys [:album_artist, :album_name, :track_name, :purchase_options]
  defstruct [
    :album_artist,
    :album_name,
    :track_name,
    :purchase_options,
  ] 
end

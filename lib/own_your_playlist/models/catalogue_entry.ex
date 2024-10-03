defmodule OwnYourPlaylist.Models.CatalogueEntry do
  @moduledoc """
  A single purchasable result from any Music Catalogue.
  """

  @enforce_keys [:album_artist, :album_name, :track_name, :purchase_options]
  defstruct [
    :album_artist,
    :album_name,
    :track_name,
    :purchase_options,
  ] 
end

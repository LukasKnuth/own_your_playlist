defmodule OwnYourPlaylist.Models.PurchaseOption do
  @moduledoc """
  A single purchase option for a given Track in a Music Catalogue.

  - `:description` should contain any human-readable description of what _exactly_ the
   purchase includes. For example, the Audio Format/Bitrate/etc.
  - `:shop_url` sends the user _as close to_ the specific purchase as possible in their
   browser.
  """

  @enforce_keys [:currency, :price, :description, :shop_url]
  defstruct [
    :currency,
    :price,
    :description,
    :shop_url,
  ]
end

defmodule OwnYourPlaylist.Catalogue.Qobuz do
	@moduledoc """
  Interact with the (Private) API of the [Qobuz](https://www.qobuz.com/) music
  service.
  """

  #@api_url "https://www.qobuz.com/api.json/0.2"
  @api_url "https://www.qobuz.com/v4/de-de"

  alias OwnYourPlaylist.Models.{Result, PurchaseOption}
  alias OwnYourPlaylist.External.Spotify.Models.Track
  
  def find(track) do
    client()
    |> Tesla.get("/catalog/search/autosuggest", query: [q: to_query(track)])
    |> parse_result()
  end

  defp parse_result({:ok, %{status: status, body: body}}) when status >= 200 and status < 300 do
    # TODO how do we handle uncertainty with the results? More than one?
    track = get_in(body, ["tracks", Access.at(0)])
    %Result{
      album_artist: Map.get(track, "artist"),
      album_name: Map.get(track, "album"),
      track_name: Map.get(track, "title"),
      purchase_options: [%PurchaseOption{
        currency: "N/A",
        price: "N/A",
        description: "High Quality MP3",
        shop_url: Map.get(track, "url")
      }]
    }
  end

  # TODO make this beter.. Reuse from Spotify and have general client?
  defp parse_result(other), do: other

  defp to_query(%Track{artist_names: [main_artist | _], album_name: album, name: name}) do
    "#{main_artist} #{album} #{name}"
  end

  defp client() do
    [
      {Tesla.Middleware.BaseUrl, @api_url},
      {Tesla.Middleware.Headers, [{"X-Requested-With", "XMLHttpRequest"}]},
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end
end

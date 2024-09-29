defmodule OwnYourPlaylist.External.SevenDigital do
	@moduledoc """
  A client for the (Private) 7digital Catalogue API.
  """
  alias OwnYourPlaylist.Models.PurchaseOption
  alias OwnYourPlaylist.Models.Result
  alias OwnYourPlaylist.External.Spotify.Models.Track

  @api_url "https://api.7digital.com/1.2"

  def find(track) do
    query = [
      q: to_query(track),
      usageTypes: "download",
      pageSize: 1,
      shopId: 265, # TODO this is DE, get other lang codes and make this an explicit param!
      oauth_consumer_key: "7drfpc993qp5" # This is set static in JS. Magic constant?
    ]
    client()
    |> Tesla.get("/track/search", query: query)
    |> parse_result()
  end

  defp parse_result({:ok, %{status: status, body: body}}) when status >= 200 and status < 300 do
    track = get_in(body, ["searchResults", "searchResult", Access.at(0), "track"])
    shop_url = to_url(track)
    %Result{
      track_name: Map.get(track, "title"),
      album_name: get_in(track, ["release", "title"]),
      album_artist: get_in(track, ["release", "artist", "name"]),
      purchase_options: Enum.map(get_in(track, ["download", "packages"]), &parse_option(&1, shop_url))
    }
  end

  # TODO make this beter.. Reuse from Spotify and have general client?
  defp parse_result(other), do: other

  defp to_url(track) do
    artist_slug = get_in(track, ["release", "artist", "slug"])
    release_slug = get_in(track, ["release", "slug"])
    # TODO build dynamically with correct shop region!
    "https://de.7digital.com/artist/#{artist_slug}/release/#{release_slug}"
  end

  defp parse_option(package, shop_url) do
    formats = get_in(package, ["formats", Access.all(), "description"])
    %PurchaseOption{
      currency: get_in(package, ["price", "currencyCode"]),
      price: get_in(package, ["price", "sevendigitalPrice"]),
      description: "#{Map.get(package, "description")} (#{Enum.join(formats, " / ")})",
      shop_url: shop_url
    }
  end

  defp to_query(%Track{artist_names: [main_artist | _], album_name: album, name: name}) do
    "#{main_artist} #{album} #{name}"
  end

  defp client() do
    [
      {Tesla.Middleware.BaseUrl, @api_url},
      {Tesla.Middleware.Headers, [{"accept", "application/json"}]},
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end
end

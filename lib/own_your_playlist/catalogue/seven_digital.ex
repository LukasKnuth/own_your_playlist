defmodule OwnYourPlaylist.Catalogue.SevenDigital do
	@moduledoc """
  A client for the (Private) 7digital Catalogue API.
  """
  import OwnYourPlaylist.Util.TeslaResponse
  alias OwnYourPlaylist.Models.PurchaseOption
  alias OwnYourPlaylist.Models.CatalogueEntry
  alias OwnYourPlaylist.Models.Track

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
    |> handle_response()
    |> parse()
  end

  defp parse({:ok, body}) do
    body
    |> get_in(["searchResults", "searchResult", Access.at(0), "track"])
    |> parse_result()
  end
  defp parse(other), do: other

  defp to_url(track) do
    artist_slug = get_in(track, ["release", "artist", "slug"])
    release_slug = get_in(track, ["release", "slug"])
    # TODO build dynamically with correct shop region!
    "https://de.7digital.com/artist/#{artist_slug}/release/#{release_slug}"
  end

  defp parse_result(nil), do: {:error, :not_found}
  defp parse_result(track) do
    shop_url = to_url(track)
    {:ok, %CatalogueEntry{
      track_name: Map.get(track, "title"),
      album_name: get_in(track, ["release", "title"]),
      album_artist: get_in(track, ["release", "artist", "name"]),
      purchase_options: Enum.map(get_in(track, ["download", "packages"]), &parse_option(&1, shop_url))
    }}
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
      {Tesla.Middleware.Timeout, timeout: :timer.seconds(10)},
      {Tesla.Middleware.Retry, delay: 200, max_retries: 3, should_retry: &should_retry/1},
      {Tesla.Middleware.BaseUrl, @api_url},
      {Tesla.Middleware.Headers, [{"accept", "application/json"}]},
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end

  defp should_retry({:error, _reason}), do: true
  defp should_retry({:ok, %{status: status}}) when status >= 400, do: true
  defp should_retry(_), do: false
end

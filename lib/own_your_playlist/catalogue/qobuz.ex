defmodule OwnYourPlaylist.Catalogue.Qobuz do
	@moduledoc """
  Interact with the (Private) API of the [Qobuz](https://www.qobuz.com/) music
  service.
  """

  @api_url "https://www.qobuz.com/v4/de-de"

  import OwnYourPlaylist.Util.TeslaResponse
  alias OwnYourPlaylist.Models.{CatalogueEntry, Track, PurchaseOption}
  
  def find(track) do
    client()
    |> Tesla.get("/catalog/search/autosuggest", query: [q: to_query(track)])
    |> handle_response()
    |> parse()
  end

  defp parse({:ok, body}) do
    # TODO how do we handle uncertainty with the results? More than one?
    body
    |> get_in(["tracks", Access.at(0)])
    |> parse_result()
  end
  defp parse(other), do: other

  defp parse_result(nil), do: {:error, :not_found}
  defp parse_result(track) do
    {:ok, %CatalogueEntry{
      album_artist: Map.get(track, "artist"),
      album_name: Map.get(track, "album"),
      track_name: Map.get(track, "title"),
      purchase_options: [%PurchaseOption{
        currency: "N/A",
        price: "N/A",
        description: "High Quality MP3",
        shop_url: Map.get(track, "url")
      }]
    }}
  end

  defp to_query(%Track{artist_names: [main_artist | _], album_name: album, name: name}) do
    "#{main_artist} #{album} #{name}"
  end

  defp client() do
    [
      {Tesla.Middleware.Timeout, timeout: :timer.seconds(10)},
      {Tesla.Middleware.Retry, delay: 200, max_retries: 3, should_retry: &should_retry/1},
      {Tesla.Middleware.BaseUrl, @api_url},
      {Tesla.Middleware.Headers, [{"X-Requested-With", "XMLHttpRequest"}]},
      Tesla.Middleware.JSON
    ]
    |> Tesla.client()
  end

  defp should_retry({:error, _reason}), do: true
  defp should_retry({:ok, %{status: status}}) when status >= 400, do: true
  defp should_retry(_), do: false
end

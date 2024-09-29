defmodule OwnYourPlaylist.External.Qobuz do
	@moduledoc """
  Interact with the (Private) API of the [Qobuz](https://www.qobuz.com/) music
  service.
  """

  #@api_url "https://www.qobuz.com/api.json/0.2"
  @api_url "https://www.qobuz.com/v4/de-de"

  alias OwnYourPlaylist.External.Spotify.Models.Track

  def find(track) do
    client()
    |> Tesla.get("/catalog/search/autosuggest", query: [q: to_query(track)])
  end

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

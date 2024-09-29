defmodule OwnYourPlaylist.External.SevenDigital do
	@moduledoc """
  A client for the (Private) 7digital Catalogue API.
  """
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

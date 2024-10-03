defmodule OwnYourPlaylist.Catalogue do
  @moduledoc """
  Main ineraction point with any external catalogues to buy and own music from.
  """
  alias OwnYourPlaylist.Models.CatalogueEntry
  alias Phoenix.PubSub
  alias OwnYourPlaylist.Async
  alias OwnYourPlaylist.Catalogue.{Qobuz, SevenDigital}

  @pubsub OwnYourPlaylist.PubSub
  @async_opts [
    ordered: false,
    timeout: :timer.seconds(20),
    on_timeout: :kill_task
  ]
  @catalogues [
    Qobuz,
    SevenDigital,
    # TODO bandcamp
  ]

  def find_all(topic, tracks) do
    work = tracks_in_all_catalogues(tracks)
    opts = Keyword.put(@async_opts, :max_concurrency, length(work))
    Async
    |> Task.Supervisor.async_stream_nolink(work, &find_in/1, opts)
    |> Stream.each(&publish_result(topic, &1))
    |> Stream.run()
  end

  defp tracks_in_all_catalogues(tracks) do
    Enum.flat_map(tracks, fn track ->
      [track]
      |> Stream.cycle()
      |> Enum.zip(@catalogues)
    end)
  end

  defp find_in({track, catalogue}), do: catalogue.find(track)

  # TODO they should have easier IDs...
  defp publish_result(topic, {:ok, %CatalogueEntry{} = result}) do
    PubSub.broadcast(@pubsub, topic, {:found, "song_id", "catalogue_id", result})
  end
  defp publish_result(topic, {:error, _reason}) do
    PubSub.broadcast(@pubsub, topic, {:fail, "song_id", "catalogue_id"})
  end
end

defmodule OwnYourPlaylistWeb.Live.Landing do
  @moduledoc """
  The initial landing page to start the process of analyzing a playlist.
  """
  use OwnYourPlaylistWeb, :live_view

  alias OwnYourPlaylist.Streamer.Spotify

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_form(socket, "", nil)}
  end

  @impl true
  def handle_event("process", %{"link" => link}, socket) do
    {:noreply, parse_link(socket, link)}
  end

  defp parse_link(socket, link) do
    case Spotify.id_from_link(link) do
      {:ok, id} ->
        # TODO use generated ID for processes, otherwise we can send garbage via direct URL.
        push_navigate(socket, to: ~p"/process/#{id}")

      {:error, {:not_a_playlist, _path}} ->
        assign_form(socket, link, {"Must link to a Playlist", []})

      {:error, {:unsupported_service, _host}} ->
        assign_form(socket, link, {"Expects open.spotify.com links", []})
    end
  end

  defp assign_form(socket, link, error) do
    errors = if is_nil(error), do: [], else: [link: error]
    form = to_form(%{"link" => link}, errors: errors)
    assign(socket, :form, form)
  end
end

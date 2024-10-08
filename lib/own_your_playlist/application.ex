defmodule OwnYourPlaylist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OwnYourPlaylistWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:own_your_playlist, :dns_cluster_query) || :ignore},
      OwnYourPlaylist.Finch,
      OwnYourPlaylist.Streamer.Spotify.TokenJob,
      {Phoenix.PubSub, name: OwnYourPlaylist.PubSub},
      {Task.Supervisor, name: OwnYourPlaylist.Async},
      OwnYourPlaylistWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: OwnYourPlaylist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OwnYourPlaylistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

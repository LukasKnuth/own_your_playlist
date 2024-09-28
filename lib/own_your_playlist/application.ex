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
      {Phoenix.PubSub, name: OwnYourPlaylist.PubSub},
      OwnYourPlaylist.Finch,
      # Start a worker by calling: OwnYourPlaylist.Worker.start_link(arg)
      # {OwnYourPlaylist.Worker, arg},
      # Start to serve requests, typically the last entry
      OwnYourPlaylistWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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

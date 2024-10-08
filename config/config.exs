# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :own_your_playlist,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :own_your_playlist, OwnYourPlaylistWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OwnYourPlaylistWeb.ErrorHTML, json: OwnYourPlaylistWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: OwnYourPlaylist.PubSub,
  live_view: [signing_salt: "cUIxBHUC"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  own_your_playlist: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  own_your_playlist: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_handler,
  formatter: {LoggerJSON.Formatters.Basic, metadata: :all}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Finch as the Tesla Adapter
config :tesla, :adapter, {Tesla.Adapter.Finch, name: OwnYourPlaylist.Finch}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

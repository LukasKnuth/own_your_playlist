import Config

# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :own_your_playlist, OwnYourPlaylistWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "zTN7sNQCagwIFZECLDZuPM3ureGEPOxTufMHjTqRodUY+GZTe/HMBfLNhAGtSU43",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:own_your_playlist, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:own_your_playlist, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :own_your_playlist, OwnYourPlaylistWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/own_your_playlist_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :own_your_playlist, dev_routes: true

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :own_your_playlist, OwnYourPlaylist.Streamer.Spotify.Account,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")

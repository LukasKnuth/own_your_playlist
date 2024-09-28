import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :own_your_playlist, OwnYourPlaylistWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "P/5kC3yEdidQa5FHZwTCEYqWUg5ubznqQct65HmSRP1pOAbbwL5EgxCJDRnAncP6",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

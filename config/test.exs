import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :p2p, P2pWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

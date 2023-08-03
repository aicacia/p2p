import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :p2p, P2pWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3UozhJgicc6ITekdQZTdkuFN9++U8/0MHfF0zfUBXm7HEqRpcdDiisdY7rlAH2gq",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

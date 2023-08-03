# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :p2p, P2pWeb.Endpoint,
  check_origin: false,
  render_errors: [
    formats: [json: P2pWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: P2p.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :p2p, generators: [binary_id: true]

config :cors_plug,
  origin: ~r/.*/,
  methods: ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE"]

config :joken, default_signer: :crypto.strong_rand_bytes(128) |> Base.url_encode64()

config :bcrypt_elixir, log_rounds: 4

config :peerage,
  via: Peerage.Via.Self,
  dns_name: "localhost",
  app_name: "p2p",
  log_results: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

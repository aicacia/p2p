# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :p2p, P2pWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: P2pWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: P2p.PubSub,
  live_view: [signing_salt: "NtxLRDl8"]

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

config :joken, default_signer: "secret"

config :bcrypt_elixir, log_rounds: 4

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

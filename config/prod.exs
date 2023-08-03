import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :peerage,
  via: Peerage.Via.Dns,
  dns_name: "p2p.api"

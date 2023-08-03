defmodule P2p.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      P2pWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: P2p.PubSub},
      # Start the Endpoint (http/https)
      P2pWeb.Endpoint
      # Start a worker by calling: P2p.Worker.start_link(arg)
      # {P2p.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: P2p.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    P2pWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

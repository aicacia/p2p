defmodule P2pWeb.Router do
  use P2pWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", P2pWeb do
    pipe_through :api

    post "/client", Controller, :client
    post "/device", Controller, :device
  end
end

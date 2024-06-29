defmodule P2pWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :p2p

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  # @session_options [
  #  store: :cookie,
  #  key: "_p2p_key",
  #  signing_salt: "WB3lKHpW",
  #  same_site: "Lax"
  # ]

  # socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  socket "/client", P2pWeb.Client,
    websocket: [
      max_frame_size: 8192,
      compress: true
    ],
    longpoll: false

  socket "/server", P2pWeb.Server,
    websocket: [
      max_frame_size: 8192,
      compress: true
    ],
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  # plug Plug.Static,
  #   at: "/",
  #   from: :p2p,
  #   gzip: false

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug CORSPlug
  plug P2pWeb.Router
end

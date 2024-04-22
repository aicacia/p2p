defmodule P2pWeb.Plug do
  use P2pWeb, :controller

  def origin(conn) do
    origin = get_req_header(conn, "origin") |> List.first()

    if origin == nil do
      ["*"]
    else
      [origin]
    end
  end
end

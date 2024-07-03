defmodule P2pWeb.Authentication do
  use P2pWeb, :controller

  require Logger

  @bearer "Bearer "
  @bearer_length String.length(@bearer)

  def init(opts), do: opts

  def call(conn, _opts \\ []) do
    authorization =
      get_req_header(conn, "authorization") |> List.first()

    authorize_connection(conn, authorization)
  end

  defp authorize_connection(conn, nil) do
    conn
    |> send_resp(401, "")
    |> halt()
  end

  defp authorize_connection(conn, authorization) do
    token = String.slice(authorization, @bearer_length..-1//1)

    case P2pWeb.Token.verify_and_validate(token) do
      {:ok, %{"sub" => server_id}} ->
        conn |> assign(:server_id, server_id)

      {:error, reason} ->
        IO.puts(reason)

        conn
        |> send_resp(401, "")
        |> halt()
    end
  end
end

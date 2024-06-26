defmodule P2pWeb.Controller do
  use P2pWeb, :controller

  require Logger

  action_fallback P2pWeb.FallbackController

  def client(conn, %{"id" => server_id, "password" => password} = _params) do
    uuid = UUID.uuid4()
    :ok = P2pWeb.Endpoint.subscribe("authenticate:#{server_id}:#{uuid}")

    P2pWeb.Endpoint.broadcast!("server:#{server_id}", "validate", %{
      from: uuid,
      password: password
    })

    receive do
      %Phoenix.Socket.Broadcast{event: "validate", payload: valid} ->
        P2pWeb.Endpoint.unsubscribe("authenticate:#{server_id}:#{uuid}")

        if valid do
          {:ok, token, _claims} =
            P2pWeb.Token.generate_and_sign(%{server_id: server_id, uuid: uuid})

          put_status(conn, 201) |> text(token)
        else
          send_resp(conn, 401, "")
        end
    after
      5_000 ->
        P2pWeb.Endpoint.unsubscribe("authenticate:#{server_id}:#{uuid}")
        send_resp(conn, 500, "")
    end
  end

  def server(conn, %{"password" => password} = _params) do
    server_id = conn.assigns.server_id
    encrypted_password = Bcrypt.hash_pwd_salt(password)
    uuid = P2p.Servers.uuid(server_id, encrypted_password)

    if P2p.Servers.has?(uuid) do
      send_resp(conn, 403, "")
    else
      {:ok, token, _claims} =
        P2pWeb.Token.generate_and_sign(%{
          server_id: server_id,
          uuid: uuid,
          encrypted_password: encrypted_password
        })

      Logger.info("New Server #{uuid}")
      put_status(conn, 201) |> text(token)
    end
  end

  def health(conn, _params) do
    json(conn, %{ok: true})
  end
end

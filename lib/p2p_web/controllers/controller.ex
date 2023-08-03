defmodule P2pWeb.Controller do
  alias P2p.Servers
  use P2pWeb, :controller

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
      60_000 ->
        P2pWeb.Endpoint.unsubscribe("authenticate:#{server_id}:#{uuid}")
        send_resp(conn, 500, "")
    end
  end

  def server(conn, %{"id" => server_id, "password" => password} = _params) do
    if Servers.has?(server_id) do
      send_resp(conn, 403, "")
    else
      {:ok, token, _claims} =
        P2pWeb.Token.generate_and_sign(%{
          server_id: server_id,
          uuid: UUID.uuid4(),
          encrypted_password: Bcrypt.hash_pwd_salt(password)
        })

      put_status(conn, 201) |> text(token)
    end
  end

  def health(conn, _params) do
    json(conn, %{ok: true})
  end
end

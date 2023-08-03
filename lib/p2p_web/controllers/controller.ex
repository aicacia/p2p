defmodule P2pWeb.Controller do
  use P2pWeb, :controller

  action_fallback P2pWeb.FallbackController

  def client(conn, %{"id" => device_id, "password" => password} = _params) do
    uuid = UUID.uuid4()
    :ok = P2pWeb.Endpoint.subscribe("authenticate:#{device_id}:#{uuid}")

    P2pWeb.Endpoint.broadcast!("device:#{device_id}", "validate", %{
      from: uuid,
      password: password
    })

    receive do
      %Phoenix.Socket.Broadcast{event: "validate", payload: valid} ->
        P2pWeb.Endpoint.unsubscribe("authenticate:#{device_id}:#{uuid}")

        if valid do
          {:ok, token, _claims} =
            P2pWeb.Token.generate_and_sign(%{device_id: device_id, uuid: uuid})

          text(conn, token)
        else
          send_resp(conn, 401, "")
        end
    after
      1_000 ->
        P2pWeb.Endpoint.unsubscribe("authenticate:#{device_id}:#{uuid}")
        send_resp(conn, 500, "")
    end
  end

  def device(conn, %{"id" => device_id, "password" => password} = _params) do
    {:ok, token, _claims} =
      P2pWeb.Token.generate_and_sign(%{
        device_id: device_id,
        uuid: UUID.uuid4(),
        encrypted_password: Bcrypt.hash_pwd_salt(password)
      })

    text(conn, token)
  end
end

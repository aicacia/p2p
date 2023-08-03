defmodule P2pWeb.Device do
  require Logger

  @behaviour Phoenix.Socket.Transport

  def child_spec(_opts) do
    :ignore
  end

  def drainer_spec(_opts) do
    :ignore
  end

  def connect(%{params: %{"token" => token}}) do
    {:ok, claims} = P2pWeb.Token.verify_and_validate(token)
    device_id = claims["device_id"]

    if P2p.Devices.add(device_id) do
      {:ok,
       %{
         device_id: device_id,
         uuid: claims["uuid"],
         encrypted_password: claims["encrypted_password"]
       }}
    else
      :error
    end
  end

  def init(state) do
    :ok = P2pWeb.Endpoint.subscribe("device:#{state.device_id}")
    {:ok, state}
  end

  def handle_in({payload, opts}, state) do
    case P2pWeb.Socket.JSONSerializer.decode!(payload, opts) do
      %{"to" => to, "payload" => payload} ->
        P2pWeb.Endpoint.broadcast(
          "client:#{state.device_id}:#{to}",
          "message",
          payload
        )

        {:ok, state}

      %{"password" => password} ->
        Logger.info("Device password change")

        P2pWeb.Endpoint.broadcast!(
          "client:#{state.device_id}",
          "device",
          %{type: "terminate", reason: "password_change"}
        )

        send(self(), {:change_password, Bcrypt.hash_pwd_salt(password)})
        {:ok, state}

      payload ->
        Logger.debug("Unhandled WebSocket message to Device Socket: #{inspect(payload)}")
        {:ok, state}
    end

    {:ok, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "validate",
          payload: %{from: from, password: password}
        },
        state
      ) do
    P2pWeb.Endpoint.broadcast!(
      "authenticate:#{state.device_id}:#{from}",
      "validate",
      Bcrypt.verify_pass(password, state.encrypted_password)
    )

    {:reply, :ok, {:text, Phoenix.json_library().encode!(%{type: "join", from: from})}, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "message",
          payload: %{from: from, payload: payload}
        },
        state
      ) do
    {:reply, :ok,
     {:text, Phoenix.json_library().encode!(%{type: "message", from: from, payload: payload})},
     state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "message",
          payload: %{type: "leave", from: from}
        },
        state
      ) do
    {:reply, :ok, {:text, Phoenix.json_library().encode!(%{type: "leave", from: from})}, state}
  end

  def handle_info({:change_password, encrypted_password}, state) do
    {:ok, Map.put(state, :encrypted_password, encrypted_password)}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled process message to Device Socket: #{inspect(message)}")
    {:ok, state}
  end

  def terminate(reason, state) do
    P2p.Devices.delete(state.device_id)

    P2pWeb.Endpoint.broadcast!(
      "client:#{state.device_id}",
      "device",
      %{type: "terminate", reason: reason}
    )

    :ok
  end
end

defmodule P2pWeb.Server do
  require Logger

  @behaviour Phoenix.Socket.Transport

  def child_spec(_opts) do
    :ignore
  end

  def drainer_spec(_opts) do
    :ignore
  end

  def connect(%{params: %{"token" => token}}) do
    case P2pWeb.Token.verify_and_validate(token) do
      {:ok,
       %{"server_id" => server_id, "uuid" => uuid, "encrypted_password" => encrypted_password}} ->
        if P2p.Servers.add(uuid) do
          {:ok,
           %{
             server_id: server_id,
             uuid: uuid,
             encrypted_password: encrypted_password
           }}
        else
          :error
        end

      _otherwise ->
        :error
    end
  end

  def init(state) do
    :ok = P2pWeb.Endpoint.subscribe("server:#{state.server_id}")
    {:ok, state}
  end

  def handle_in({raw_payload, [opcode: :text]}, state) do
    case Phoenix.json_library().decode!(raw_payload) do
      %{"to" => to, "payload" => payload} ->
        P2pWeb.Endpoint.broadcast(
          "client:#{state.server_id}:#{to}",
          "message",
          payload
        )

        {:ok, state}

      %{"password" => password} ->
        P2pWeb.Endpoint.broadcast!(
          "client:#{state.server_id}",
          "server",
          %{type: "terminate", reason: "password_change"}
        )

        encrypted_password = Bcrypt.hash_pwd_salt(password)
        uuid = P2p.Servers.uuid(state.server_id, encrypted_password)

        send(self(), {:change_password, encrypted_password, uuid})
        {:ok, state}

      payload ->
        Logger.debug("Unhandled WebSocket message to Server Socket: #{inspect(payload)}")
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
      "authenticate:#{state.server_id}:#{from}",
      "validate",
      Bcrypt.verify_pass(password, state.encrypted_password)
    )

    {:ok, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "join",
          payload: %{from: from}
        },
        state
      ) do
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

  def handle_info({:change_password, encrypted_password, uuid}, state) do
    P2p.Servers.delete(state.uuid)
    Logger.info("Server #{state.uuid} changed password, new uuid #{uuid}")
    {:ok, state |> Map.put(:encrypted_password, encrypted_password) |> Map.put(:uuid, uuid)}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled process message to Server Socket: #{inspect(message)}")
    {:ok, state}
  end

  def terminate(reason, state) do
    P2p.Servers.delete(state.uuid)

    P2pWeb.Endpoint.broadcast!(
      "client:#{state.server_id}",
      "server",
      %{type: "terminate", reason: reason}
    )

    :ok
  end
end

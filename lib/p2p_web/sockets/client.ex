defmodule P2pWeb.Client do
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
      {:ok, %{"server_id" => server_id, "uuid" => uuid}} ->
        {:ok, %{server_id: server_id, uuid: uuid}}

      _otherwise ->
        :error
    end
  end

  def init(state) do
    :ok = P2pWeb.Endpoint.subscribe("client:#{state.server_id}")
    :ok = P2pWeb.Endpoint.subscribe("client:#{state.server_id}:#{state.uuid}")

    P2pWeb.Endpoint.broadcast!("server:#{state.server_id}", "join", %{
      from: state.uuid
    })

    {:ok, state}
  end

  def handle_in({raw_payload, [opcode: :text]}, state) do
    P2pWeb.Endpoint.broadcast("server:#{state.server_id}", "message", %{
      from: state.uuid,
      payload: Phoenix.json_library().decode!(raw_payload)
    })

    {:ok, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "message",
          payload: payload
        },
        state
      ) do
    {:reply, :ok, {:text, Phoenix.json_library().encode!(payload)}, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "server",
          payload: %{type: "terminate", reason: reason}
        },
        state
      ) do
    Logger.debug("Client received Server terminate reason: #{reason}")
    {:stop, {:shutdown, :left}, state}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled process message to Client Socket: #{inspect(message)}")
    {:ok, state}
  end

  def terminate(_reason, state) do
    P2pWeb.Endpoint.broadcast("server:#{state.server_id}", "message", %{
      type: "leave",
      from: state.uuid
    })

    :ok
  end
end

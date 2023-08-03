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
    {:ok, claims} = P2pWeb.Token.verify_and_validate(token)
    {:ok, %{device_id: claims["device_id"], uuid: claims["uuid"]}}
  end

  def init(state) do
    :ok = P2pWeb.Endpoint.subscribe("client:#{state.device_id}")
    :ok = P2pWeb.Endpoint.subscribe("client:#{state.device_id}:#{state.uuid}")
    {:ok, state}
  end

  def handle_in({payload, opts}, state) do
    P2pWeb.Endpoint.broadcast("device:#{state.device_id}", "message", %{
      from: state.uuid,
      payload: P2pWeb.Socket.JSONSerializer.decode!(payload, opts)
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
          event: "device",
          payload: %{type: "terminate", reason: reason}
        },
        state
      ) do
    Logger.debug("Client received Device terminate reason: #{reason}")
    {:stop, {:shutdown, :left}, state}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled process message to Client Socket: #{inspect(message)}")
    {:ok, state}
  end

  def terminate(_reason, state) do
    P2pWeb.Endpoint.broadcast("device:#{state.device_id}", "message", %{
      type: "leave",
      from: state.uuid
    })

    :ok
  end
end

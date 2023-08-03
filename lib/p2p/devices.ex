defmodule P2p.Devices do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add(element) do
    GenServer.call(__MODULE__, {:add, element})
  end

  def has?(element) do
    GenServer.call(__MODULE__, {:has, element})
  end

  def delete(element) do
    GenServer.call(__MODULE__, {:delete, element})
  end

  # Callbacks

  @impl true
  def init(_opts) do
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_call({:add, element}, _from, state) do
    new_state = MapSet.put(state, element)
    {:reply, new_state != state, new_state}
  end

  @impl true
  def handle_call({:has, element}, _from, state) do
    {:reply, MapSet.member?(state, element), state}
  end

  @impl true
  def handle_call({:delete, element}, _from, state) do
    new_state = MapSet.delete(state, element)
    {:reply, new_state != state, new_state}
  end
end

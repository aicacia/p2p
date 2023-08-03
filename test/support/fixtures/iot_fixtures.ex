defmodule P2p.IOTFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `P2p.IOT` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        id: "7488a646-e31f-11e4-aace-600308960662",
        encrypted_password: "some encrypted_password"
      })
      |> P2p.IOT.create_device()

    device
  end
end

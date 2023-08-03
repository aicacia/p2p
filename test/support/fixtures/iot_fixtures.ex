defmodule P2p.IOTFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `P2p.IOT` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(%{
        id: "7488a646-e31f-11e4-aace-600308960662",
        encrypted_password: "some encrypted_password"
      })
      |> P2p.IOT.create_server()

    server
  end
end

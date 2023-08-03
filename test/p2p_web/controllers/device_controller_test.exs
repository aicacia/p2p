defmodule P2pWeb.DeviceControllerTest do
  use P2pWeb.ConnCase

  import P2p.IOTFixtures

  alias P2p.IOT.Device

  @create_attrs %{
    id: "7488a646-e31f-11e4-aace-600308960662",
    encrypted_password: "some encrypted_password"
  }
  @update_attrs %{
    id: "7488a646-e31f-11e4-aace-600308960668",
    encrypted_password: "some updated encrypted_password"
  }
  @invalid_attrs %{id: nil, encrypted_password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all devices", %{conn: conn} do
      conn = get(conn, ~p"/api/devices")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create device" do
    test "renders device when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/devices", device: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/devices/#{id}")

      assert %{
               "id" => ^id,
               "encrypted_password" => "some encrypted_password",
               "id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/devices", device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update device" do
    setup [:create_device]

    test "renders device when data is valid", %{conn: conn, device: %Device{id: id} = device} do
      conn = put(conn, ~p"/api/devices/#{device}", device: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/devices/#{id}")

      assert %{
               "id" => ^id,
               "encrypted_password" => "some updated encrypted_password",
               "id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, device: device} do
      conn = put(conn, ~p"/api/devices/#{device}", device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete device" do
    setup [:create_device]

    test "deletes chosen device", %{conn: conn, device: device} do
      conn = delete(conn, ~p"/api/devices/#{device}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/devices/#{device}")
      end
    end
  end

  defp create_device(_) do
    device = device_fixture()
    %{device: device}
  end
end

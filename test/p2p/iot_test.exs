defmodule P2p.IOTTest do
  use P2p.DataCase

  alias P2p.IOT

  describe "devices" do
    alias P2p.IOT.Device

    import P2p.IOTFixtures

    @invalid_attrs %{id: nil, encrypted_password: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert IOT.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert IOT.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{
        id: "7488a646-e31f-11e4-aace-600308960662",
        encrypted_password: "some encrypted_password"
      }

      assert {:ok, %Device{} = device} = IOT.create_device(valid_attrs)
      assert device.id == "7488a646-e31f-11e4-aace-600308960662"
      assert device.encrypted_password == "some encrypted_password"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = IOT.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()

      update_attrs = %{
        id: "7488a646-e31f-11e4-aace-600308960668",
        encrypted_password: "some updated encrypted_password"
      }

      assert {:ok, %Device{} = device} = IOT.update_device(device, update_attrs)
      assert device.id == "7488a646-e31f-11e4-aace-600308960668"
      assert device.encrypted_password == "some updated encrypted_password"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = IOT.update_device(device, @invalid_attrs)
      assert device == IOT.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = IOT.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> IOT.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = IOT.change_device(device)
    end
  end
end

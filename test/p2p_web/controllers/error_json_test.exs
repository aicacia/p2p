defmodule P2pWeb.ErrorJSONTest do
  use P2pWeb.ConnCase, async: true

  test "renders 404" do
    assert P2pWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert P2pWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

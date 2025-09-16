defmodule RiddlerAdminWebTest do
  use ExUnit.Case, async: true

  alias RiddlerAdminWeb

  describe "static_paths/0" do
    test "returns list of static paths" do
      paths = RiddlerAdminWeb.static_paths()
      assert is_list(paths)
      assert "assets" in paths
      assert "fonts" in paths
      assert "images" in paths
      assert "favicon.ico" in paths
      assert "robots.txt" in paths
    end
  end

  describe "router/0" do
    test "returns quoted expression for router" do
      result = RiddlerAdminWeb.router()
      assert is_tuple(result)
    end
  end

  describe "channel/0" do
    test "returns quoted expression for channel" do
      result = RiddlerAdminWeb.channel()
      assert is_tuple(result)
    end
  end

  describe "controller/0" do
    test "returns quoted expression for controller" do
      result = RiddlerAdminWeb.controller()
      assert is_tuple(result)
    end
  end

  describe "live_view/0" do
    test "returns quoted expression for live_view" do
      result = RiddlerAdminWeb.live_view()
      assert is_tuple(result)
    end
  end

  describe "live_component/0" do
    test "returns quoted expression for live_component" do
      result = RiddlerAdminWeb.live_component()
      assert is_tuple(result)
    end
  end

  describe "html/0" do
    test "returns quoted expression for html" do
      result = RiddlerAdminWeb.html()
      assert is_tuple(result)
    end
  end

  describe "verified_routes/0" do
    test "returns quoted expression for verified_routes" do
      result = RiddlerAdminWeb.verified_routes()
      assert is_tuple(result)
    end
  end
end

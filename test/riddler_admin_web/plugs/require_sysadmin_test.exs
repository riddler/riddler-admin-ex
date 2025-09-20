defmodule RiddlerAdminWeb.Plugs.RequireSysadminTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Plug.Conn

  alias RiddlerAdminWeb.Plugs.RequireSysadmin

  describe "RequireSysadmin plug" do
    test "allows access when user is sysadmin", %{conn: conn} do
      sysadmin = insert(:user, sysadmin: true)

      conn =
        conn
        |> assign(:current_user, sysadmin)
        |> RequireSysadmin.call([])

      refute conn.halted
    end

    test "denies access when user is not sysadmin", %{conn: conn} do
      user = insert(:user, sysadmin: false)

      conn =
        conn
        |> fetch_query_params()
        |> put_private(:phoenix_format, "html")
        |> assign(:current_user, user)
        |> RequireSysadmin.call([])

      assert conn.halted
    end
  end
end

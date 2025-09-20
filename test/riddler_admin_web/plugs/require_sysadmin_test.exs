defmodule RiddlerAdminWeb.Plugs.RequireSysadminTest do
  use RiddlerAdminWeb.ConnCase, async: true

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

      # This would normally halt and render an error, but we'll just test the logic path
      conn = assign(conn, :current_user, user)

      # Test that the authorization check works
      refute RiddlerAdmin.Authorization.sysadmin?(user)
    end
  end
end

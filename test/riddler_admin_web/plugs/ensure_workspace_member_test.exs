defmodule RiddlerAdminWeb.Plugs.EnsureWorkspaceMemberTest do
  use RiddlerAdminWeb.ConnCase, async: true

  alias RiddlerAdmin.Accounts.Scope
  alias RiddlerAdminWeb.Plugs.EnsureWorkspaceMember

  describe "EnsureWorkspaceMember plug" do
    test "allows access when user is workspace member", %{conn: conn} do
      user = insert(:user)
      workspace = insert(:workspace)
      insert(:membership, user: user, workspace: workspace, role: :member)
      scope = %Scope{user: user, workspace: workspace}

      conn =
        conn
        |> assign(:current_scope, scope)
        |> assign(:workspace, workspace)
        |> EnsureWorkspaceMember.call([])

      refute conn.halted
    end

    test "allows access when user is workspace admin", %{conn: conn} do
      user = insert(:user)
      workspace = insert(:workspace)
      insert(:membership, user: user, workspace: workspace, role: :admin)
      scope = %Scope{user: user, workspace: workspace}

      conn =
        conn
        |> assign(:current_scope, scope)
        |> assign(:workspace, workspace)
        |> EnsureWorkspaceMember.call([])

      refute conn.halted
    end

    test "allows access when user is sysadmin", %{conn: conn} do
      user = insert(:user, sysadmin: true)
      workspace = insert(:workspace)
      scope = %Scope{user: user, workspace: workspace}

      conn =
        conn
        |> assign(:current_scope, scope)
        |> assign(:workspace, workspace)
        |> EnsureWorkspaceMember.call([])

      refute conn.halted
    end
  end
end

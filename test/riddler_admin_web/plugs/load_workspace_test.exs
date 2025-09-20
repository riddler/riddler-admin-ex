defmodule RiddlerAdminWeb.Plugs.LoadWorkspaceTest do
  use RiddlerAdminWeb.ConnCase, async: true

  alias RiddlerAdmin.Accounts.Scope
  alias RiddlerAdminWeb.Plugs.LoadWorkspace

  describe "LoadWorkspace plug" do
    test "loads workspace from path parameter", %{conn: conn} do
      workspace = insert(:workspace, slug: "test-workspace")
      user = insert(:user)
      scope = Scope.for_user(user)

      conn =
        conn
        |> assign(:current_scope, scope)
        |> Map.put(:path_params, %{"workspace_slug" => "test-workspace"})
        |> LoadWorkspace.call([])

      assert conn.assigns.workspace.id == workspace.id
      assert conn.assigns.workspace_slug == "test-workspace"
      assert conn.assigns.current_scope.workspace.id == workspace.id
    end

    test "creates scope with workspace when no current_scope exists", %{conn: conn} do
      workspace = insert(:workspace, slug: "test-workspace")

      conn =
        conn
        |> Map.put(:path_params, %{"workspace_slug" => "test-workspace"})
        |> LoadWorkspace.call([])

      assert conn.assigns.workspace.id == workspace.id
      assert conn.assigns.workspace_slug == "test-workspace"
      assert conn.assigns.current_scope.workspace.id == workspace.id
      assert is_nil(conn.assigns.current_scope.user)
    end

    test "continues without workspace when no workspace_slug in path", %{conn: conn} do
      user = insert(:user)
      scope = Scope.for_user(user)

      conn =
        conn
        |> assign(:current_scope, scope)
        |> Map.put(:path_params, %{})
        |> LoadWorkspace.call([])

      refute Map.has_key?(conn.assigns, :workspace)
      refute Map.has_key?(conn.assigns, :workspace_slug)
      assert conn.assigns.current_scope == scope
    end
  end
end

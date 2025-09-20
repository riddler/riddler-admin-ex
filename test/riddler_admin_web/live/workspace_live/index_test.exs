defmodule RiddlerAdminWeb.WorkspaceLive.IndexTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import RiddlerAdmin.Factory

  describe "Workspace index" do
    test "shows empty state when user has no workspaces", %{conn: conn} do
      user = insert(:confirmed_user)

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces")

      assert html =~ "Your Workspaces"
      assert html =~ "No workspaces yet"
      assert html =~ "Create your first workspace"
      assert has_element?(lv, ~s{a[href="/workspaces/new"]})
    end

    test "displays user's workspaces when they have memberships", %{conn: conn} do
      user = insert(:confirmed_user)
      workspace1 = insert(:workspace, name: "Test Workspace 1", slug: "test-1")
      workspace2 = insert(:workspace, name: "Test Workspace 2", slug: "test-2")
      insert(:membership, user: user, workspace: workspace1, role: :admin)
      insert(:membership, user: user, workspace: workspace2, role: :member)

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces")

      assert html =~ "Your Workspaces"
      assert html =~ "Test Workspace 1"
      assert html =~ "Test Workspace 2"
      assert html =~ "/test-1"
      assert html =~ "/test-2"
      refute html =~ "No workspaces yet"

      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace1.id}"]})
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace2.id}"]})
      assert has_element?(lv, ~s{a[href="/workspaces/new"]})
    end

    test "only shows workspaces where user is a member", %{conn: conn} do
      user = insert(:confirmed_user)
      other_user = insert(:user)
      accessible_workspace = insert(:workspace, name: "My Workspace")
      inaccessible_workspace = insert(:workspace, name: "Other Workspace")

      insert(:membership, user: user, workspace: accessible_workspace, role: :member)
      insert(:membership, user: other_user, workspace: inaccessible_workspace, role: :admin)

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces")

      assert html =~ "My Workspace"
      refute html =~ "Other Workspace"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/workspaces")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

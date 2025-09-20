defmodule RiddlerAdminWeb.UserLive.DashboardTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import RiddlerAdmin.Factory

  describe "Dashboard redirect logic" do
    test "redirects to workspace creation when user has no workspaces", %{conn: conn} do
      user = insert(:confirmed_user)

      {:error, redirect} =
        conn
        |> log_in_user(user)
        |> live(~p"/dashboard")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/workspaces/new"
      assert %{"info" => "Welcome! Let's create your first workspace."} = flash
    end

    test "redirects to single workspace when user has exactly one workspace", %{conn: conn} do
      user = insert(:confirmed_user)
      workspace = insert(:workspace)
      insert(:membership, user: user, workspace: workspace, role: :admin)

      {:error, redirect} =
        conn
        |> log_in_user(user)
        |> live(~p"/dashboard")

      assert {:live_redirect, %{to: path}} = redirect
      assert path == ~p"/workspaces/#{workspace}"
    end

    test "redirects to workspace selection when user has multiple workspaces", %{conn: conn} do
      user = insert(:confirmed_user)
      workspace1 = insert(:workspace)
      workspace2 = insert(:workspace)
      insert(:membership, user: user, workspace: workspace1, role: :admin)
      insert(:membership, user: user, workspace: workspace2, role: :member)

      {:error, redirect} =
        conn
        |> log_in_user(user)
        |> live(~p"/dashboard")

      assert {:live_redirect, %{to: path}} = redirect
      assert path == ~p"/workspaces"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/dashboard")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

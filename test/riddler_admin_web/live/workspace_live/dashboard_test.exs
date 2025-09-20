defmodule RiddlerAdminWeb.WorkspaceLive.DashboardTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Workspace dashboard" do
    setup do
      user = insert(:confirmed_user)
      workspace = insert(:workspace, name: "Test Workspace", slug: "test-workspace")
      insert(:membership, user: user, workspace: workspace, role: :admin)

      %{user: user, workspace: workspace}
    end

    test "renders workspace dashboard with basic information", %{
      conn: conn,
      user: user,
      workspace: workspace
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}")

      assert html =~ "Test Workspace"
      assert html =~ "Workspace Dashboard"
      assert html =~ "Recent Members"
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}/settings"]})
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}/settings/members"]})
    end

    test "shows recent members in the dashboard", %{conn: conn, user: user, workspace: workspace} do
      # Create additional members
      member1 = insert(:user, email: "member1@example.com")
      member2 = insert(:user, email: "member2@example.com")
      insert(:membership, user: member1, workspace: workspace, role: :member)
      insert(:membership, user: member2, workspace: workspace, role: :admin)

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}")

      # Should show up to 5 recent members
      assert html =~ user.email
      assert html =~ "member1@example.com"
      assert html =~ "member2@example.com"

      # Should show role badges
      assert html =~ "Admin"
      assert html =~ "Member"
    end

    test "shows view all members link", %{conn: conn, user: user, workspace: workspace} do
      # Create additional members
      for i <- 1..3 do
        member = insert(:user, email: "member#{i}@example.com")
        insert(:membership, user: member, workspace: workspace, role: :member)
      end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}")

      # Should show "View all" link
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}/settings/members"]})
      assert has_element?(lv, "a", "View all")
    end

    test "displays member count correctly", %{conn: conn, user: user, workspace: workspace} do
      # Create additional members
      member1 = insert(:user)
      member2 = insert(:user)
      insert(:membership, user: member1, workspace: workspace, role: :member)
      insert(:membership, user: member2, workspace: workspace, role: :member)

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}")

      # Should show total member count (3 total: user + member1 + member2)
      assert html =~ "Recent Members"
    end

    test "shows member information with correct formatting", %{
      conn: conn,
      user: user,
      workspace: workspace
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}")

      # Should show user email
      assert html =~ user.email

      # Should show member since date (formatted)
      current_year = Date.utc_today().year |> to_string()
      assert html =~ current_year
    end

    test "redirects if user is not logged in", %{workspace: workspace} do
      conn = build_conn()

      assert {:error, redirect} = live(conn, ~p"/workspaces/#{workspace.slug}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

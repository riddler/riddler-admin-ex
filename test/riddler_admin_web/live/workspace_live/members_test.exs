defmodule RiddlerAdminWeb.WorkspaceLive.MembersTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Workspace members index" do
    setup do
      admin_user = insert(:confirmed_user, email: "admin@example.com")
      workspace = insert(:workspace, name: "Test Workspace", slug: "test-workspace")
      insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      %{admin_user: admin_user, workspace: workspace}
    end

    test "renders members list", %{conn: conn, admin_user: admin_user, workspace: workspace} do
      # Add some additional members
      member1 = insert(:confirmed_user, email: "member1@example.com")
      member2 = insert(:confirmed_user, email: "member2@example.com")
      insert(:membership, user: member1, workspace: workspace, role: :member)
      insert(:membership, user: member2, workspace: workspace, role: :admin)

      {:ok, lv, html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert html =~ "Test Workspace Members"
      assert html =~ "Manage workspace members and permissions"
      assert html =~ "admin@example.com"
      assert html =~ "member1@example.com"
      assert html =~ "member2@example.com"
      assert html =~ "Members (3)"

      # Check for role badges
      assert html =~ "Admin"
      assert html =~ "Member"

      # Check for action buttons
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}/settings"]})
      assert has_element?(lv, "button[phx-click=\"remove_member\"]")
    end

    test "shows correct member count", %{conn: conn, admin_user: admin_user, workspace: workspace} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert html =~ "Members (1)"
    end

    test "displays member information correctly", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      # Should show user avatar initial
      assert html =~ String.upcase(String.first(admin_user.email))

      # Should show formatted join date
      current_year = Date.utc_today().year |> to_string()
      assert html =~ current_year
    end
  end

  describe "Edit member" do
    setup do
      admin_user = insert(:confirmed_user, email: "admin@example.com")
      member_user = insert(:confirmed_user, email: "member@example.com")
      workspace = insert(:workspace, name: "Test Workspace", slug: "test-workspace")
      admin_membership = insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      member_membership =
        insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        admin_user: admin_user,
        member_user: member_user,
        workspace: workspace,
        admin_membership: admin_membership,
        member_membership: member_membership
      }
    end

    test "renders edit member form", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace,
      member_membership: member_membership
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/members/#{member_membership.id}/edit")

      assert html =~ "Edit Member: member@example.com"
      assert has_element?(lv, "#member-form")
      assert has_element?(lv, ~s{select[name="membership[role]"]})
      assert has_element?(lv, ~s{option[value="member"]})
      assert has_element?(lv, ~s{option[value="admin"]})
    end

    test "validates member form on change", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace,
      member_membership: member_membership
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/members/#{member_membership.id}/edit")

      result =
        lv
        |> element("#member-form")
        |> render_change(%{
          "membership" => %{"role" => "admin"}
        })

      assert result =~ "Edit Member"
    end

    test "updates member successfully", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace,
      member_membership: member_membership
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/members/#{member_membership.id}/edit")

      assert render_submit(lv, :update_member, %{
               "membership" => %{"role" => "admin"}
             })

      # Verify the membership was updated
      updated_membership =
        RiddlerAdmin.Workspaces.get_membership(member_membership.user, workspace)

      assert updated_membership.role == :admin
    end

    test "handles update errors gracefully", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace,
      member_membership: member_membership
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/members/#{member_membership.id}/edit")

      # Try to submit with invalid role (this would normally be prevented by the form, but let's test error handling)
      result =
        lv
        |> element("#member-form")
        |> render_change(%{
          "membership" => %{"role" => "invalid_role"}
        })

      assert result =~ "Edit Member"
    end

    test "redirects to members list when member not found", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      assert {:error, {:live_redirect, %{to: to_path, flash: flash}}} =
               conn
               |> log_in_user(admin_user)
               |> live(~p"/workspaces/#{workspace.slug}/members/nonexistent-id/edit")

      assert to_path == ~p"/workspaces/#{workspace.slug}/settings/members"
      assert %{"error" => "Member not found."} = flash
    end
  end

  describe "Remove member" do
    setup do
      admin_user = insert(:confirmed_user)
      member_user = insert(:confirmed_user)
      workspace = insert(:workspace, slug: "test-workspace")
      insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      member_membership =
        insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        admin_user: admin_user,
        member_user: member_user,
        workspace: workspace,
        member_membership: member_membership
      }
    end

    test "removes member successfully", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace,
      member_membership: member_membership
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      result = render_click(lv, :remove_member, %{"membership-id" => member_membership.id})

      assert result =~ "Member removed successfully"

      # Verify the membership was actually deleted
      assert RiddlerAdmin.Workspaces.get_membership(member_membership.user, workspace) == nil
    end

    test "handles remove member when member not found", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      result = render_click(lv, :remove_member, %{"membership-id" => "nonexistent-id"})

      assert result =~ "Member not found"
    end
  end

  describe "Member access control" do
    setup do
      workspace = insert(:workspace, slug: "test-workspace")
      admin_user = insert(:confirmed_user)
      member_user = insert(:confirmed_user)
      non_member = insert(:confirmed_user)

      insert(:membership, user: admin_user, workspace: workspace, role: :admin)
      insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        workspace: workspace,
        admin_user: admin_user,
        member_user: member_user,
        non_member: non_member
      }
    end

    test "allows admin to access members page", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert html =~ "Members"
    end

    test "allows regular member to view members page", %{
      conn: conn,
      member_user: member_user,
      workspace: workspace
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(member_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert html =~ "Members"
    end

    test "redirects if user is not logged in", %{workspace: workspace} do
      conn = build_conn()

      assert {:error, redirect} = live(conn, ~p"/workspaces/#{workspace.slug}/settings/members")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "Navigation" do
    setup do
      admin_user = insert(:confirmed_user)
      workspace = insert(:workspace, slug: "test-workspace")
      insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      %{admin_user: admin_user, workspace: workspace}
    end

    test "provides navigation back to settings", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}/settings"]})
    end

    test "provides edit links for each member", %{
      conn: conn,
      admin_user: admin_user,
      workspace: workspace
    } do
      member_user = insert(:confirmed_user)

      member_membership =
        insert(:membership, user: member_user, workspace: workspace, role: :member)

      {:ok, lv, _html} =
        conn
        |> log_in_user(admin_user)
        |> live(~p"/workspaces/#{workspace.slug}/settings/members")

      assert has_element?(
               lv,
               ~s{a[href="/workspaces/#{workspace.slug}/members/#{member_membership.id}/edit"]}
             )
    end
  end
end

defmodule RiddlerAdminWeb.WorkspaceLive.SettingsTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import RiddlerAdmin.Factory

  describe "Workspace settings" do
    setup do
      user = insert(:confirmed_user)
      workspace = insert(:workspace, name: "Test Workspace", slug: "test-workspace")
      insert(:membership, user: user, workspace: workspace, role: :admin)

      %{user: user, workspace: workspace}
    end

    test "renders settings page for admin", %{conn: conn, user: user, workspace: workspace} do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}/settings")

      assert html =~ "Test Workspace Settings"
      assert html =~ "Manage your workspace configuration"
      assert has_element?(lv, "#workspace-settings-form")
      assert has_element?(lv, ~s{input[name="workspace[name]"]})
      assert has_element?(lv, ~s{input[name="workspace[slug]"]})
      assert has_element?(lv, ~s{a[href="/workspaces/#{workspace.slug}"]})
    end

    test "updates workspace with valid data", %{conn: conn, user: user, workspace: workspace} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}/settings")

      result =
        lv
        |> form("#workspace-settings-form", %{
          "workspace" => %{
            "name" => "Updated Workspace",
            "slug" => "updated-workspace"
          }
        })
        |> render_submit()

      assert result =~ "Workspace updated successfully!"
      assert result =~ "Updated Workspace"

      # Verify workspace was actually updated
      updated_workspace = RiddlerAdmin.Workspaces.get_workspace!(workspace.id)
      assert updated_workspace.name == "Updated Workspace"
      assert updated_workspace.slug == "updated-workspace"
    end

    test "renders errors with invalid data (phx-change)", %{
      conn: conn,
      user: user,
      workspace: workspace
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}/settings")

      result =
        lv
        |> element("#workspace-settings-form")
        |> render_change(%{
          "workspace" => %{
            "name" => "",
            "slug" => ""
          }
        })

      assert result =~ "Test Workspace Settings"
      assert result =~ "can&#39;t be blank"
    end

    test "renders errors with invalid data (phx-submit)", %{
      conn: conn,
      user: user,
      workspace: workspace
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}/settings")

      result =
        lv
        |> form("#workspace-settings-form", %{
          "workspace" => %{
            "name" => "",
            "slug" => ""
          }
        })
        |> render_submit()

      assert result =~ "Test Workspace Settings"
      assert result =~ "can&#39;t be blank"
    end

    test "deletes workspace when user is admin", %{conn: conn, user: user, workspace: workspace} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/#{workspace.slug}/settings")

      # Click delete button
      assert render_click(lv, "delete")

      # Verify workspace was deleted
      assert_raise Ecto.NoResultsError, fn ->
        RiddlerAdmin.Workspaces.get_workspace!(workspace.id)
      end
    end

    test "redirects if user is not logged in", %{workspace: workspace} do
      conn = build_conn()

      assert {:error, redirect} = live(conn, ~p"/workspaces/#{workspace.slug}/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

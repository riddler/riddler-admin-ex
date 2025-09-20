defmodule RiddlerAdminWeb.WorkspaceLive.NewTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import RiddlerAdmin.Factory

  alias RiddlerAdmin.Workspaces

  describe "New workspace" do
    test "renders create workspace form", %{conn: conn} do
      user = insert(:confirmed_user)

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/new")

      assert html =~ "Create Workspace"
      assert html =~ "Set up a new workspace for your team"
      assert has_element?(lv, "#workspace-form")
      assert has_element?(lv, ~s{input[name="workspace[name]"]})
      assert has_element?(lv, ~s{input[name="workspace[slug]"]})
      assert has_element?(lv, ~s{button[type="submit"]})
    end

    test "creates workspace with valid data", %{conn: conn} do
      user = insert(:confirmed_user)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/new")

      form =
        lv
        |> form("#workspace-form", %{
          "workspace" => %{
            "name" => "Test Workspace",
            "slug" => "test-workspace"
          }
        })

      assert render_submit(form)

      # Verify workspace was actually created
      workspace = Workspaces.get_workspace_by_slug("test-workspace")
      assert workspace.name == "Test Workspace"
      assert workspace.slug == "test-workspace"

      # Verify user became admin of the workspace
      membership = Workspaces.get_membership(user, workspace)
      assert membership.role == :admin
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      user = insert(:confirmed_user)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/new")

      result =
        lv
        |> element("#workspace-form")
        |> render_change(%{
          "workspace" => %{
            "name" => "",
            "slug" => ""
          }
        })

      assert result =~ "Create Workspace"
      assert result =~ "can&#39;t be blank"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      user = insert(:confirmed_user)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/new")

      result =
        lv
        |> form("#workspace-form", %{
          "workspace" => %{
            "name" => "",
            "slug" => ""
          }
        })
        |> render_submit()

      assert result =~ "Create Workspace"
      assert result =~ "can&#39;t be blank"
    end

    test "renders errors with duplicate slug", %{conn: conn} do
      user = insert(:confirmed_user)
      insert(:workspace, slug: "duplicate-slug")

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workspaces/new")

      result =
        lv
        |> form("#workspace-form", %{
          "workspace" => %{
            "name" => "New Workspace",
            "slug" => "duplicate-slug"
          }
        })
        |> render_submit()

      assert result =~ "Create Workspace"
      assert result =~ "has already been taken"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/workspaces/new")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

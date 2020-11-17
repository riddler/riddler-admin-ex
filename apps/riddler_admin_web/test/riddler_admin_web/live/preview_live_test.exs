defmodule RiddlerAdminWeb.PreviewLiveTest do
  use RiddlerAdminWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RiddlerAdmin.Previews

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp fixture(:preview) do
    {:ok, preview} = Previews.create_preview(@create_attrs)
    preview
  end

  defp create_preview(_) do
    preview = fixture(:preview)
    %{preview: preview}
  end

  describe "Index" do
    setup [:create_preview]

    test "lists all previews", %{conn: conn, preview: preview} do
      {:ok, _index_live, html} = live(conn, Routes.preview_index_path(conn, :index))

      assert html =~ "Listing Previews"
    end

    test "saves new preview", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.preview_index_path(conn, :index))

      assert index_live |> element("a", "New Preview") |> render_click() =~
               "New Preview"

      assert_patch(index_live, Routes.preview_index_path(conn, :new))

      assert index_live
             |> form("#preview-form", preview: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#preview-form", preview: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.preview_index_path(conn, :index))

      assert html =~ "Preview created successfully"
    end

    test "updates preview in listing", %{conn: conn, preview: preview} do
      {:ok, index_live, _html} = live(conn, Routes.preview_index_path(conn, :index))

      assert index_live |> element("#preview-#{preview.id} a", "Edit") |> render_click() =~
               "Edit Preview"

      assert_patch(index_live, Routes.preview_index_path(conn, :edit, preview))

      assert index_live
             |> form("#preview-form", preview: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#preview-form", preview: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.preview_index_path(conn, :index))

      assert html =~ "Preview updated successfully"
    end

    test "deletes preview in listing", %{conn: conn, preview: preview} do
      {:ok, index_live, _html} = live(conn, Routes.preview_index_path(conn, :index))

      assert index_live |> element("#preview-#{preview.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#preview-#{preview.id}")
    end
  end

  describe "Show" do
    setup [:create_preview]

    test "displays preview", %{conn: conn, preview: preview} do
      {:ok, _show_live, html} = live(conn, Routes.preview_show_path(conn, :show, preview))

      assert html =~ "Show Preview"
    end

    test "updates preview within modal", %{conn: conn, preview: preview} do
      {:ok, show_live, _html} = live(conn, Routes.preview_show_path(conn, :show, preview))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Preview"

      assert_patch(show_live, Routes.preview_show_path(conn, :edit, preview))

      assert show_live
             |> form("#preview-form", preview: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#preview-form", preview: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.preview_show_path(conn, :show, preview))

      assert html =~ "Preview updated successfully"
    end
  end
end

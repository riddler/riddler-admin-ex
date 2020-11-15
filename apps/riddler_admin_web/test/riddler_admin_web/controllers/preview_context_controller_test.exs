defmodule RiddlerAdminWeb.PreviewContextControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.Previews

  @create_attrs %{data: %{}}
  @update_attrs %{data: %{}}
  @invalid_attrs %{data: nil}

  def fixture(:preview_context) do
    {:ok, preview_context} = Previews.create_preview_context(@create_attrs)
    preview_context
  end

  describe "index" do
    test "lists all preview_contexts", %{conn: conn} do
      conn = get(conn, Routes.preview_context_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Preview contexts"
    end
  end

  describe "new preview_context" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.preview_context_path(conn, :new))
      assert html_response(conn, 200) =~ "New Preview context"
    end
  end

  describe "create preview_context" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.preview_context_path(conn, :create), preview_context: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.preview_context_path(conn, :show, id)

      conn = get(conn, Routes.preview_context_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Preview context"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.preview_context_path(conn, :create), preview_context: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Preview context"
    end
  end

  describe "edit preview_context" do
    setup [:create_preview_context]

    test "renders form for editing chosen preview_context", %{conn: conn, preview_context: preview_context} do
      conn = get(conn, Routes.preview_context_path(conn, :edit, preview_context))
      assert html_response(conn, 200) =~ "Edit Preview context"
    end
  end

  describe "update preview_context" do
    setup [:create_preview_context]

    test "redirects when data is valid", %{conn: conn, preview_context: preview_context} do
      conn = put(conn, Routes.preview_context_path(conn, :update, preview_context), preview_context: @update_attrs)
      assert redirected_to(conn) == Routes.preview_context_path(conn, :show, preview_context)

      conn = get(conn, Routes.preview_context_path(conn, :show, preview_context))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, preview_context: preview_context} do
      conn = put(conn, Routes.preview_context_path(conn, :update, preview_context), preview_context: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Preview context"
    end
  end

  describe "delete preview_context" do
    setup [:create_preview_context]

    test "deletes chosen preview_context", %{conn: conn, preview_context: preview_context} do
      conn = delete(conn, Routes.preview_context_path(conn, :delete, preview_context))
      assert redirected_to(conn) == Routes.preview_context_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.preview_context_path(conn, :show, preview_context))
      end
    end
  end

  defp create_preview_context(_) do
    preview_context = fixture(:preview_context)
    %{preview_context: preview_context}
  end
end

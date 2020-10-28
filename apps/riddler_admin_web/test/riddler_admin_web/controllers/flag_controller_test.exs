defmodule RiddlerAdminWeb.FlagControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.Flags

  @create_attrs %{key: "some key", type: "some type"}
  @update_attrs %{key: "some updated key", type: "some updated type"}
  @invalid_attrs %{key: nil, type: nil}

  def fixture(:flag) do
    {:ok, flag} = Flags.create_flag(@create_attrs)
    flag
  end

  describe "index" do
    test "lists all flags", %{conn: conn} do
      conn = get(conn, Routes.flag_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Flags"
    end
  end

  describe "new flag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.flag_path(conn, :new))
      assert html_response(conn, 200) =~ "New Flag"
    end
  end

  describe "create flag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.flag_path(conn, :create), flag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.flag_path(conn, :show, id)

      conn = get(conn, Routes.flag_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Flag"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.flag_path(conn, :create), flag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Flag"
    end
  end

  describe "edit flag" do
    setup [:create_flag]

    test "renders form for editing chosen flag", %{conn: conn, flag: flag} do
      conn = get(conn, Routes.flag_path(conn, :edit, flag))
      assert html_response(conn, 200) =~ "Edit Flag"
    end
  end

  describe "update flag" do
    setup [:create_flag]

    test "redirects when data is valid", %{conn: conn, flag: flag} do
      conn = put(conn, Routes.flag_path(conn, :update, flag), flag: @update_attrs)
      assert redirected_to(conn) == Routes.flag_path(conn, :show, flag)

      conn = get(conn, Routes.flag_path(conn, :show, flag))
      assert html_response(conn, 200) =~ "some updated key"
    end

    test "renders errors when data is invalid", %{conn: conn, flag: flag} do
      conn = put(conn, Routes.flag_path(conn, :update, flag), flag: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Flag"
    end
  end

  describe "delete flag" do
    setup [:create_flag]

    test "deletes chosen flag", %{conn: conn, flag: flag} do
      conn = delete(conn, Routes.flag_path(conn, :delete, flag))
      assert redirected_to(conn) == Routes.flag_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.flag_path(conn, :show, flag))
      end
    end
  end

  defp create_flag(_) do
    flag = fixture(:flag)
    %{flag: flag}
  end
end

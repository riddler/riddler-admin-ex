defmodule RiddlerAdminWeb.EnvironmentControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.Environments

  @create_attrs %{key: "some key", name: "some name"}
  @update_attrs %{key: "some updated key", name: "some updated name"}
  @invalid_attrs %{key: nil, name: nil}

  def fixture(:environment) do
    {:ok, environment} = Environments.create_environment(@create_attrs)
    environment
  end

  describe "index" do
    test "lists all environments", %{conn: conn} do
      conn = get(conn, Routes.environment_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Environments"
    end
  end

  describe "new environment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.environment_path(conn, :new))
      assert html_response(conn, 200) =~ "New Environment"
    end
  end

  describe "create environment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.environment_path(conn, :create), environment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.environment_path(conn, :show, id)

      conn = get(conn, Routes.environment_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Environment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.environment_path(conn, :create), environment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Environment"
    end
  end

  describe "edit environment" do
    setup [:create_environment]

    test "renders form for editing chosen environment", %{conn: conn, environment: environment} do
      conn = get(conn, Routes.environment_path(conn, :edit, environment))
      assert html_response(conn, 200) =~ "Edit Environment"
    end
  end

  describe "update environment" do
    setup [:create_environment]

    test "redirects when data is valid", %{conn: conn, environment: environment} do
      conn = put(conn, Routes.environment_path(conn, :update, environment), environment: @update_attrs)
      assert redirected_to(conn) == Routes.environment_path(conn, :show, environment)

      conn = get(conn, Routes.environment_path(conn, :show, environment))
      assert html_response(conn, 200) =~ "some updated key"
    end

    test "renders errors when data is invalid", %{conn: conn, environment: environment} do
      conn = put(conn, Routes.environment_path(conn, :update, environment), environment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Environment"
    end
  end

  describe "delete environment" do
    setup [:create_environment]

    test "deletes chosen environment", %{conn: conn, environment: environment} do
      conn = delete(conn, Routes.environment_path(conn, :delete, environment))
      assert redirected_to(conn) == Routes.environment_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.environment_path(conn, :show, environment))
      end
    end
  end

  defp create_environment(_) do
    environment = fixture(:environment)
    %{environment: environment}
  end
end

defmodule RiddlerAdminWeb.AccountControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Identities

  @identity_attrs %{email: "foo@bar.com", password: "Zaq1Xsw2Cde3"}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def setup() do
    {:ok,
     %{
       conn: build_conn()
     }}
  end

  def fixture(:account) do
    {:ok, identity} = Identities.register_identity(@identity_attrs)
    fixture(:account, identity)
  end

  def fixture(:account, %{id: owner_id}) do
    {:ok, account} = Accounts.create_account_with_owner(@create_attrs, owner_id)
    account
  end

  defp assert_login_redirect(conn) do
    assert Routes.identity_session_path(conn, :new) == redirected_to(conn)
  end

  describe "when not logged in" do
    test "index redirects", %{conn: conn} do
      conn
      |> get(Routes.account_path(conn, :index))
      |> assert_login_redirect()
    end

    test "new redirects", %{conn: conn} do
      conn
      |> get(Routes.account_path(conn, :new))
      |> assert_login_redirect()
    end

    test "create redirects", %{conn: conn} do
      conn
      |> post(Routes.account_path(conn, :create, %{}))
      |> assert_login_redirect()
    end

    test "show redirects", %{conn: conn} do
      conn
      |> get(Routes.account_path(conn, :show, "anything"))
      |> assert_login_redirect()
    end

    test "edit redirects", %{conn: conn} do
      conn
      |> get(Routes.account_path(conn, :edit, "anything"))
      |> assert_login_redirect()
    end

    test "update redirects", %{conn: conn} do
      conn
      |> put(Routes.account_path(conn, :update, "anything", %{}))
      |> assert_login_redirect()
    end

    test "delete redirects", %{conn: conn} do
      conn
      |> delete(Routes.account_path(conn, :delete, "anything"))
      |> assert_login_redirect()
    end
  end

  describe "index" do
    setup :register_and_log_in_identity

    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Accounts"
    end
  end

  describe "new account" do
    setup :register_and_log_in_identity

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :new))
      assert html_response(conn, 200) =~ "New Account"
    end
  end

  describe "create account" do
    setup :register_and_log_in_identity

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.account_path(conn, :show, id)

      conn = get(conn, Routes.account_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Account"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Account"
    end
  end

  describe "edit account" do
    setup [:register_and_log_in_identity, :create_account]

    test "renders form for editing chosen account", %{conn: conn, account: account} do
      conn = get(conn, Routes.account_path(conn, :edit, account))
      assert html_response(conn, 200) =~ "Edit Account"
    end
  end

  describe "update account" do
    setup [:register_and_log_in_identity, :create_account]

    test "redirects when data is valid", %{conn: conn, account: account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @update_attrs)
      assert redirected_to(conn) == Routes.account_path(conn, :show, account)

      conn = get(conn, Routes.account_path(conn, :show, account))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Account"
    end
  end

  describe "delete account" do
    setup [:register_and_log_in_identity, :create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      conn = delete(conn, Routes.account_path(conn, :delete, account))
      assert redirected_to(conn) == Routes.account_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.account_path(conn, :show, account))
      end
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    %{account: account}
  end
end

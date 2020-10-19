defmodule RiddlerAdminWeb.AccountController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Accounts.Account

  def index(%{assigns: %{current_identity: current_identity}} = conn, _params) do
    accounts = Accounts.list_owned_accounts(current_identity)
    render(conn, "index.html", accounts: accounts)
  end

  def new(conn, _params) do
    changeset = Accounts.change_account(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    account_params
    |> Accounts.create_account_with_owner(conn.assigns.current_identity.id)
    |> case do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.html", account: account)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    changeset = Accounts.change_account(account)
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    case Accounts.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    {:ok, _account} = Accounts.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: Routes.account_path(conn, :index))
  end
end

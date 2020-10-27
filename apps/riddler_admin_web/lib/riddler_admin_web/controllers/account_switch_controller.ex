defmodule RiddlerAdminWeb.AccountSwitchController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts

  @doc """
  Switches the current Account.

  It updates the session with the new account_id
  """
  def switch(conn, %{"account_id" => account_id} = _params) do
    account = Accounts.get_account!(account_id)

    conn
    |> put_session(:current_account_id, account.id)
    |> redirect(to: Routes.workspace_path(conn, :index))
  end
end

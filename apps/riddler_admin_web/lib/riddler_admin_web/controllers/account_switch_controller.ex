defmodule RiddlerAdminWeb.AccountSwitchController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdminWeb.AccountSwitch

  @doc """
  Switches the current Account.

  It updates the session with the new account_id
  """
  def switch(conn, %{"account_id" => account_id} = _params) do
    account = Accounts.get_account!(account_id)

    conn
    |> AccountSwitch.switch_current_account(account, params)
    |> redirect(to: Routes.workspace_path(conn, :index))
  end
end

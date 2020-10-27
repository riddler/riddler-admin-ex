defmodule RiddlerAdminWeb.AccountSwitchController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdminWeb.AccountSwitch

  # Swtich the current_account
  def switch(conn, %{"account_id" => account_id} = params) do
    account = Accounts.get_account!(account_id)

    conn
    |> AccountSwitch.switch_current_account(account, params)
    |> redirect(to: Routes.account_workspace_path(conn, :index, account_id))
  end
end

defmodule RiddlerAdminWeb.AccountSwitchController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdminWeb.AccountSwitch

  def switch(conn, %{"account_id" => account_id} = params) do
    account = Accounts.get_account!(account_id)
    AccountSwitch.switch_current_account(conn, account, params)
  end

  # # Swtich the current_account
  # def switch(conn, %{"id" => id} = params) do
  #   IO.inspect(conn)
  #   IO.inspect(params)

  #   account = Accounts.get_account!(id)
  #   changeset = Accounts.change_account(account)
  #   render(conn, "edit.html", account: account, changeset: changeset)
  # end
end

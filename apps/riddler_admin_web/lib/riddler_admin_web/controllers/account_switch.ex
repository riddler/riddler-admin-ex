defmodule RiddlerAdminWeb.AccountSwitch do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Switches the current Account.

  It updates the session with the new account_id
  """
  def switch_current_account(conn, %{id: id} = _account, _params \\ %{}) do
    conn
    |> put_session(:current_account_id, id)
  end
end

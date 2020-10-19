defmodule RiddlerAdminWeb.AccountSwitch do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Switches the current Account.

  It updates the session with the new account_id
  """
  def switch_current_account(conn, %{id: id} = _account, _params \\ %{}) do
    # token = Identities.generate_identity_session_token(identity)
    # identity_return_to = get_session(conn, :identity_return_to)

    conn
    |> put_session(:current_account_id, id)
    |> redirect(to: "/workspaces")
  end
end

defmodule RiddlerAdminWeb.WorkspaceSwitch do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Switches the current Workspace.

  It updates the session with the new workspace_id
  """
  def switch_current_workspace(conn, %{id: id} = _workspace, _params \\ %{}) do
    conn
    |> put_session(:current_workspace_id, id)
  end
end

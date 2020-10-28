defmodule RiddlerAdminWeb.WorkspaceSwitchController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdminWeb.WorkspaceSwitch

  # Swtich the current_workspace
  def switch(conn, %{"workspace_id" => workspace_id} = params) do
    workspace = Workspaces.get_workspace!(workspace_id)

    conn
    |> WorkspaceSwitch.switch_current_workspace(workspace, params)
    |> redirect(to: Routes.workspace_agent_path(conn, :index, workspace_id))
  end
end

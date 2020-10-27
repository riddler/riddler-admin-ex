defmodule RiddlerAdminWeb.WorkspaceController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  def index(conn, _params) do
    account_id =
      conn
      |> get_session(:current_account_id)

    workspaces = Workspaces.list_account_workspaces(account_id)

    render(conn, "index.html",
      account_id: account_id,
      workspaces: workspaces
    )
  end

  def new(conn, _params) do
    changeset = Workspaces.change_workspace(%Workspace{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"workspace" => workspace_params}) do
    account_id =
      conn
      |> get_session(:current_account_id)

    case Workspaces.create_workspace_with_account_and_owner(
           workspace_params,
           account_id,
           conn.assigns.current_identity.id
         ) do
      {:ok, workspace} ->
        conn
        |> put_flash(:info, "Workspace created successfully.")
        |> redirect(to: Routes.workspace_path(conn, :show, workspace))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    workspace = Workspaces.get_workspace!(id)
    render(conn, "show.html", workspace: workspace)
  end

  def edit(conn, %{"id" => id}) do
    workspace = Workspaces.get_workspace!(id)
    changeset = Workspaces.change_workspace(workspace)
    render(conn, "edit.html", workspace: workspace, changeset: changeset)
  end

  def update(conn, %{"id" => id, "workspace" => workspace_params}) do
    workspace = Workspaces.get_workspace!(id)

    case Workspaces.update_workspace(workspace, workspace_params) do
      {:ok, workspace} ->
        conn
        |> put_flash(:info, "Workspace updated successfully.")
        |> redirect(to: Routes.workspace_path(conn, :show, workspace))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", workspace: workspace, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    workspace = Workspaces.get_workspace!(id)
    {:ok, _workspace} = Workspaces.delete_workspace(workspace)

    conn
    |> put_flash(:info, "Workspace deleted successfully.")
    |> redirect(to: Routes.workspace_path(conn, :index))
  end
end

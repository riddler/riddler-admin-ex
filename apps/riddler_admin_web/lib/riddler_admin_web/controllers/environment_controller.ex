defmodule RiddlerAdminWeb.EnvironmentController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Environments
  alias RiddlerAdmin.Environments.Environment

  def index(conn, %{"workspace_id" => workspace_id}) do
    environments = Environments.list_workspace_environments(workspace_id)
    render(conn, "index.html", environments: environments, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = Environments.change_environment(%Environment{})

    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{
        "environment" => environment_params,
        "workspace_id" => workspace_id
      }) do
    case Environments.create_environment(environment_params, workspace_id) do
      {:ok, environment} ->
        conn
        |> put_flash(:info, "Environment created successfully.")
        |> redirect(
          to:
            Routes.workspace_environment_path(
              conn,
              :show,
              workspace_id,
              environment
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    environment = Environments.get_environment!(id)
    render(conn, "show.html", environment: environment, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    environment = Environments.get_environment!(id)
    changeset = Environments.change_environment(environment)

    render(conn, "edit.html",
      environment: environment,
      changeset: changeset,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "environment" => environment_params,
        "workspace_id" => workspace_id
      }) do
    environment = Environments.get_environment!(id)

    case Environments.update_environment(environment, environment_params) do
      {:ok, environment} ->
        conn
        |> put_flash(:info, "Environment updated successfully.")
        |> redirect(to: Routes.workspace_environment_path(conn, :show, workspace_id, environment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          environment: environment,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    environment = Environments.get_environment!(id)
    {:ok, _environment} = Environments.delete_environment(environment)

    conn
    |> put_flash(:info, "Environment deleted successfully.")
    |> redirect(to: Routes.workspace_environment_path(conn, :index, workspace_id))
  end
end

defmodule RiddlerAdminWeb.EnvironmentController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Environments
  alias RiddlerAdmin.Environments.Environment

  def index(conn, _params) do
    environments = Environments.list_environments()
    render(conn, "index.html", environments: environments)
  end

  def new(conn, _params) do
    changeset = Environments.change_environment(%Environment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"environment" => environment_params}) do
    case Environments.create_environment(environment_params) do
      {:ok, environment} ->
        conn
        |> put_flash(:info, "Environment created successfully.")
        |> redirect(to: Routes.environment_path(conn, :show, environment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    environment = Environments.get_environment!(id)
    render(conn, "show.html", environment: environment)
  end

  def edit(conn, %{"id" => id}) do
    environment = Environments.get_environment!(id)
    changeset = Environments.change_environment(environment)
    render(conn, "edit.html", environment: environment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "environment" => environment_params}) do
    environment = Environments.get_environment!(id)

    case Environments.update_environment(environment, environment_params) do
      {:ok, environment} ->
        conn
        |> put_flash(:info, "Environment updated successfully.")
        |> redirect(to: Routes.environment_path(conn, :show, environment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", environment: environment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    environment = Environments.get_environment!(id)
    {:ok, _environment} = Environments.delete_environment(environment)

    conn
    |> put_flash(:info, "Environment deleted successfully.")
    |> redirect(to: Routes.environment_path(conn, :index))
  end
end

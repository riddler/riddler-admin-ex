defmodule RiddlerAdminWeb.ConditionController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Conditions
  alias RiddlerAdmin.Conditions.Condition

  def index(conn, %{"workspace_id" => workspace_id}) do

    conditions = Conditions.list_workspace_conditions(workspace_id)
    render(conn, "index.html", conditions: conditions, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = Conditions.change_condition(%Condition{})
    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{"condition" => condition_params, "workspace_id" => workspace_id}) do
    case Conditions.create_condition_with_workspace(condition_params, workspace_id) do
      {:ok, condition} ->
        conn
        |> put_flash(:info, "Condition created successfully.")
        |> redirect(to: Routes.workspace_condition_path(conn, :show, workspace_id, condition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    condition = Conditions.get_condition!(id)
    render(conn, "show.html", condition: condition, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    condition = Conditions.get_condition!(id)
    changeset = Conditions.change_condition(condition)
    render(conn, "edit.html", condition: condition, changeset: changeset, workspace_id: workspace_id)
  end

  def update(conn, %{"id" => id, "condition" => condition_params, "workspace_id" => workspace_id}) do
    condition = Conditions.get_condition!(id)

    case Conditions.update_condition(condition, condition_params) do
      {:ok, condition} ->
        conn
        |> put_flash(:info, "Condition updated successfully.")
        |> redirect(to: Routes.workspace_condition_path(conn, :show, workspace_id, condition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", condition: condition, changeset: changeset, workspace_id: workspace_id)
    end
  end

  def delete(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    condition = Conditions.get_condition!(id)
    {:ok, _condition} = Conditions.delete_condition(condition)

    conn
    |> put_flash(:info, "Condition deleted successfully.")
    |> redirect(to: Routes.workspace_condition_path(conn, :index, workspace_id))
  end
end

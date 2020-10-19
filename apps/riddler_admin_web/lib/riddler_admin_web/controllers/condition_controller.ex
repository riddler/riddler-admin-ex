defmodule RiddlerAdminWeb.ConditionController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Conditions
  alias RiddlerAdmin.Conditions.Condition

  def index(conn, _params) do
    account_id =
      conn
      |> get_session(:current_account_id)

    conditions = Conditions.list_account_conditions(account_id)
    render(conn, "index.html", conditions: conditions)
  end

  def new(conn, _params) do
    changeset = Conditions.change_condition(%Condition{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"condition" => condition_params}) do
    account_id =
      conn
      |> get_session(:current_account_id)

    case Conditions.create_condition_with_account(condition_params, account_id) do
      {:ok, condition} ->
        conn
        |> put_flash(:info, "Condition created successfully.")
        |> redirect(to: Routes.condition_path(conn, :show, condition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    condition = Conditions.get_condition!(id)
    render(conn, "show.html", condition: condition)
  end

  def edit(conn, %{"id" => id}) do
    condition = Conditions.get_condition!(id)
    changeset = Conditions.change_condition(condition)
    render(conn, "edit.html", condition: condition, changeset: changeset)
  end

  def update(conn, %{"id" => id, "condition" => condition_params}) do
    condition = Conditions.get_condition!(id)

    case Conditions.update_condition(condition, condition_params) do
      {:ok, condition} ->
        conn
        |> put_flash(:info, "Condition updated successfully.")
        |> redirect(to: Routes.condition_path(conn, :show, condition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", condition: condition, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    condition = Conditions.get_condition!(id)
    {:ok, _condition} = Conditions.delete_condition(condition)

    conn
    |> put_flash(:info, "Condition deleted successfully.")
    |> redirect(to: Routes.condition_path(conn, :index))
  end
end

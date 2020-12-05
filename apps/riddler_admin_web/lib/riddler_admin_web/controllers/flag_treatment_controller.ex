defmodule RiddlerAdminWeb.FlagTreatmentController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Flags
  alias RiddlerAdmin.Flags.FlagTreatment

  def index(conn, %{"workspace_id" => workspace_id, "flag_id" => flag_id}) do
    treatments = Flags.list_flag_treatments(flag_id)

    render(conn, "index.html",
      treatments: treatments,
      flag_id: flag_id,
      workspace_id: workspace_id
    )
  end

  def new(conn, %{"workspace_id" => workspace_id, "flag_id" => flag_id}) do
    changeset = Flags.change_flag_treatment(%FlagTreatment{})

    render(conn, "new.html",
      changeset: changeset,
      workspace_id: workspace_id,
      flag_id: flag_id
    )
  end

  def create(conn, %{
        "flag_treatment" => flag_treatment_params,
        "workspace_id" => workspace_id,
        "flag_id" => flag_id
      }) do
    case Flags.create_flag_treatment(flag_treatment_params, flag_id) do
      {:ok, flag_treatment} ->
        conn
        |> put_flash(:info, "FlagTreatment created successfully.")
        |> redirect(
          to:
            Routes.workspace_flag_flag_treatment_path(
              conn,
              :show,
              workspace_id,
              flag_id,
              flag_treatment
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          workspace_id: workspace_id,
          flag_id: flag_id
        )
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id, "flag_id" => flag_id}) do
    flag_treatment = Flags.get_flag_treatment!(id)

    render(conn, "show.html",
      flag_treatment: flag_treatment,
      workspace_id: workspace_id,
      flag_id: flag_id
    )
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id, "flag_id" => flag_id}) do
    flag_treatment = Flags.get_flag_treatment!(id)
    changeset = Flags.change_flag_treatment(flag_treatment)

    render(conn, "edit.html",
      flag_treatment: flag_treatment,
      changeset: changeset,
      workspace_id: workspace_id,
      flag_id: flag_id
    )
  end

  def update(conn, %{
        "id" => id,
        "flag_treatment" => flag_treatment_params,
        "workspace_id" => workspace_id,
        "flag_id" => flag_id
      }) do
    flag_treatment = Flags.get_flag_treatment!(id)

    case Flags.update_flag_treatment(flag_treatment, flag_treatment_params) do
      {:ok, flag_treatment} ->
        conn
        |> put_flash(:info, "FlagTreatment updated successfully.")
        |> redirect(
          to:
            Routes.workspace_flag_flag_treatment_path(
              conn,
              :show,
              workspace_id,
              flag_id,
              flag_treatment
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          flag_treatment: flag_treatment,
          changeset: changeset,
          workspace_id: workspace_id,
          flag_id: flag_id
        )
    end
  end

  def delete(conn, %{
        "id" => id,
        "workspace_id" => workspace_id,
        "flag_id" => flag_id
      }) do
    flag_treatment = Flags.get_flag_treatment!(id)
    {:ok, _flag_treatment} = Flags.delete_flag_treatment(flag_treatment)

    conn
    |> put_flash(:info, "FlagTreatment deleted successfully.")
    |> redirect(
      to: Routes.workspace_flag_flag_treatment_path(conn, :index, workspace_id, flag_id)
    )
  end
end

defmodule RiddlerAdminWeb.FlagAssignerController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Flags
  alias RiddlerAdmin.Flags.FlagAssigner

  def index(conn, %{"workspace_id" => workspace_id, "flag_id" => flag_id}) do
    assigners = Flags.list_flag_assigners(flag_id)

    render(conn, "index.html",
      assigners: assigners,
      flag_id: flag_id,
      workspace_id: workspace_id
    )
  end

  def new(conn, %{"workspace_id" => workspace_id, "flag_id" => flag_id}) do
    Flags.change_flag_assigner(%FlagAssigner{})
    |> render_new(conn, workspace_id, flag_id)
  end

  def create(conn, %{
        "flag_assigner" => flag_assigner_params,
        "workspace_id" => workspace_id,
        "flag_id" => flag_id
      }) do
    case Flags.create_flag_assigner(flag_assigner_params, flag_id) do
      {:ok, flag_assigner} ->
        conn
        |> put_flash(:info, "FlagAssigner created successfully.")
        |> redirect(
          to:
            Routes.workspace_flag_flag_assigner_path(
              conn,
              :show,
              workspace_id,
              flag_id,
              flag_assigner
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset
        |> render_new(conn, workspace_id, flag_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id, "flag_id" => flag_id}) do
    flag_assigner = Flags.get_flag_assigner!(id)

    render(conn, "show.html",
      flag_assigner: flag_assigner,
      workspace_id: workspace_id,
      flag_id: flag_id
    )
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id, "flag_id" => flag_id}) do
    flag_assigner = Flags.get_flag_assigner!(id)

    Flags.change_flag_assigner(flag_assigner)
    |> render_edit(conn, flag_assigner, workspace_id, flag_id)
  end

  def update(conn, %{
        "id" => id,
        "flag_assigner" => flag_assigner_params,
        "workspace_id" => workspace_id,
        "flag_id" => flag_id
      }) do
    flag_assigner = Flags.get_flag_assigner!(id)

    case Flags.update_flag_assigner(flag_assigner, flag_assigner_params) do
      {:ok, flag_assigner} ->
        conn
        |> put_flash(:info, "FlagAssigner updated successfully.")
        |> redirect(
          to:
            Routes.workspace_flag_flag_assigner_path(
              conn,
              :show,
              workspace_id,
              flag_id,
              flag_assigner
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          flag_assigner: flag_assigner,
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
    flag_assigner = Flags.get_flag_assigner!(id)
    {:ok, _flag_assigner} = Flags.delete_flag_assigner(flag_assigner)

    conn
    |> put_flash(:info, "FlagAssigner deleted successfully.")
    |> redirect(to: Routes.workspace_flag_flag_assigner_path(conn, :index, workspace_id, flag_id))
  end

  defp render_new(changeset, conn, workspace_id, flag_id) do
    flag_treatments = Flags.list_flag_treatments(flag_id)

    render(conn, "new.html",
      changeset: changeset,
      workspace_id: workspace_id,
      flag_id: flag_id,
      flag_treatments: flag_treatments
    )
  end

  defp render_edit(changeset, conn, flag_assigner, workspace_id, flag_id) do
    flag_treatments = Flags.list_flag_treatments(flag_id)

    render(conn, "edit.html",
      flag_assigner: flag_assigner,
      changeset: changeset,
      workspace_id: workspace_id,
      flag_id: flag_id,
      flag_treatments: flag_treatments
    )
  end
end

defmodule RiddlerAdminWeb.FlagController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Flags
  alias RiddlerAdmin.Flags.Flag

  def index(conn, %{"workspace_id" => workspace_id}) do
    flags = Flags.list_workspace_flags(workspace_id)
    render(conn, "index.html", flags: flags, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = Flags.change_flag(%Flag{})

    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{
        "flag" => flag_params,
        "workspace_id" => workspace_id
      }) do
    case Flags.create_flag(flag_params, workspace_id) do
      {:ok, flag} ->
        conn
        |> put_flash(:info, "Flag created successfully.")
        |> redirect(
          to:
            Routes.workspace_flag_path(
              conn,
              :show,
              workspace_id,
              flag
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    flag = Flags.get_flag!(id)
    render(conn, "show.html", flag: flag, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    flag = Flags.get_flag!(id)
    changeset = Flags.change_flag(flag)

    render(conn, "edit.html", flag: flag, changeset: changeset, workspace_id: workspace_id)
  end

  def update(conn, %{
        "id" => id,
        "flag" => flag_params,
        "workspace_id" => workspace_id
      }) do
    flag = Flags.get_flag!(id)

    case Flags.update_flag(flag, flag_params) do
      {:ok, flag} ->
        conn
        |> put_flash(:info, "Flag updated successfully.")
        |> redirect(to: Routes.workspace_flag_path(conn, :show, workspace_id, flag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          flag: flag,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    flag = Flags.get_flag!(id)
    {:ok, _flag} = Flags.delete_flag(flag)

    conn
    |> put_flash(:info, "Flag deleted successfully.")
    |> redirect(to: Routes.workspace_flag_path(conn, :index, workspace_id))
  end
end

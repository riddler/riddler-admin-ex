defmodule RiddlerAdminWeb.PreviewContextController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Previews
  alias RiddlerAdmin.Previews.PreviewContext

  def index(conn, %{"workspace_id" => workspace_id}) do
    preview_contexts = Previews.list_workspace_preview_contexts(workspace_id)
    render(conn, "index.html", preview_contexts: preview_contexts, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = Previews.change_preview_context(%PreviewContext{})

    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{
        "preview_context" => %{"data" => data} = preview_context_params,
        "workspace_id" => workspace_id
      }) do
    %{preview_context_params | "data" => YamlElixir.read_from_string!(data)}
    |> Previews.create_preview_context(workspace_id)
    |> case do
      {:ok, preview_context} ->
        conn
        |> put_flash(:info, "PreviewContext created successfully.")
        |> redirect(
          to:
            Routes.workspace_preview_context_path(
              conn,
              :show,
              workspace_id,
              preview_context
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    preview_context = Previews.get_preview_context!(id)
    render(conn, "show.html", preview_context: preview_context, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    %{data: data} = preview_context = Previews.get_preview_context!(id)
    changeset = Previews.change_preview_context(%{preview_context | data: Ymlr.document!(data)})

    render(conn, "edit.html",
      preview_context: preview_context,
      changeset: changeset,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "preview_context" => %{"data" => data} = preview_context_params,
        "workspace_id" => workspace_id
      }) do
    preview_context = Previews.get_preview_context!(id)

    case Previews.update_preview_context(preview_context, %{
           preview_context_params
           | "data" => YamlElixir.read_from_string!(data)
         }) do
      {:ok, preview_context} ->
        conn
        |> put_flash(:info, "PreviewContext updated successfully.")
        |> redirect(
          to: Routes.workspace_preview_context_path(conn, :show, workspace_id, preview_context)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          preview_context: preview_context,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    preview_context = Previews.get_preview_context!(id)
    {:ok, _preview_context} = Previews.delete_preview_context(preview_context)

    conn
    |> put_flash(:info, "PreviewContext deleted successfully.")
    |> redirect(to: Routes.workspace_preview_context_path(conn, :index, workspace_id))
  end
end

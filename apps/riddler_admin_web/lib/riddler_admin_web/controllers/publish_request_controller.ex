defmodule RiddlerAdminWeb.PublishRequestController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.PublishRequests
  alias RiddlerAdmin.PublishRequests.PublishRequest

  def index(conn, %{"workspace_id" => workspace_id}) do
    publish_requests = PublishRequests.list_workspace_publish_requests(workspace_id)
    render(conn, "index.html", publish_requests: publish_requests, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = PublishRequests.change_publish_request(%PublishRequest{})

    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(%{assigns: %{current_identity: %{id: author_id}}} = conn, %{
        "publish_request" => publish_request_params,
        "workspace_id" => workspace_id
      }) do
    case PublishRequests.create_publish_request(publish_request_params, workspace_id, author_id) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "PublishRequest created successfully.")
        |> redirect(
          to:
            Routes.workspace_publish_request_path(
              conn,
              :show,
              workspace_id,
              publish_request
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    definition = Ymlr.document!(publish_request.data)

    render(conn, "show.html",
      publish_request: publish_request,
      workspace_id: workspace_id,
      definition: definition
    )
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    changeset = PublishRequests.change_publish_request(publish_request)

    render(conn, "edit.html",
      publish_request: publish_request,
      changeset: changeset,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "publish_request" => publish_request_params,
        "workspace_id" => workspace_id
      }) do
    publish_request = PublishRequests.get_publish_request!(id)

    case PublishRequests.update_publish_request(publish_request, publish_request_params) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "PublishRequest updated successfully.")
        |> redirect(
          to: Routes.workspace_publish_request_path(conn, :show, workspace_id, publish_request)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          publish_request: publish_request,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workdspace_id" => workspace_id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    {:ok, _publish_request} = PublishRequests.delete_publish_request(publish_request)

    conn
    |> put_flash(:info, "PublishRequest deleted successfully.")
    |> redirect(to: Routes.workspace_publish_request_path(conn, :index, workspace_id))
  end
end
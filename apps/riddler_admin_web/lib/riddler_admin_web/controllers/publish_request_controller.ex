defmodule RiddlerAdminWeb.PublishRequestController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.PublishRequests
  alias RiddlerAdmin.PublishRequests.PublishRequest

  def index(conn, _params) do
    publish_requests = PublishRequests.list_publish_requests()
    render(conn, "index.html", publish_requests: publish_requests)
  end

  def new(conn, _params) do
    changeset = PublishRequests.change_publish_request(%PublishRequest{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"publish_request" => publish_request_params}) do
    case PublishRequests.create_publish_request(publish_request_params) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "Publish request created successfully.")
        |> redirect(to: Routes.publish_request_path(conn, :show, publish_request))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    render(conn, "show.html", publish_request: publish_request)
  end

  def edit(conn, %{"id" => id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    changeset = PublishRequests.change_publish_request(publish_request)
    render(conn, "edit.html", publish_request: publish_request, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publish_request" => publish_request_params}) do
    publish_request = PublishRequests.get_publish_request!(id)

    case PublishRequests.update_publish_request(publish_request, publish_request_params) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "Publish request updated successfully.")
        |> redirect(to: Routes.publish_request_path(conn, :show, publish_request))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", publish_request: publish_request, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publish_request = PublishRequests.get_publish_request!(id)
    {:ok, _publish_request} = PublishRequests.delete_publish_request(publish_request)

    conn
    |> put_flash(:info, "Publish request deleted successfully.")
    |> redirect(to: Routes.publish_request_path(conn, :index))
  end
end

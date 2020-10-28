defmodule RiddlerAdminWeb.ApprovalController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.PublishRequests

  @doc """
  Approves the provided PublishRequest
  """
  def approve(
        conn,
        %{"publish_request_id" => publish_request_id, "workspace_id" => workspace_id} = _params
      ) do
    pr = PublishRequests.get_publish_request!(publish_request_id)

    case PublishRequests.approve(pr, conn.assigns.current_identity) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "PublishRequest approved successfully.")
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
        render(conn, "show.html", changeset: changeset, workspace_id: workspace_id)
    end
  end
end

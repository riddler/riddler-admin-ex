defmodule RiddlerAdminWeb.PublishController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.PublishRequests
  alias RiddlerAdmin.PublishRequests.UseCases.PublishDefinition
  alias RiddlerAdmin.Definitions

  @doc """
  Publishes the provided PublishRequest.
  """
  def publish_request(
        conn,
        %{"publish_request_id" => publish_request_id, "workspace_id" => workspace_id} = _params
      ) do
    pr = PublishRequests.get_publish_request!(publish_request_id)

    case PublishRequests.publish(pr, conn.assigns.current_identity) do
      {:ok, publish_request} ->
        conn
        |> put_flash(:info, "PublishRequest published successfully.")
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

  @doc """
  Re-publishes the provided Definition.
  """
  def definition(
        conn,
        %{"definition_id" => definition_id, "workspace_id" => workspace_id} = _params
      ) do
    definition = Definitions.get_definition!(definition_id)

    definition
    |> PublishDefinition.new()
    |> PublishDefinition.execute()

    conn
    |> put_flash(:info, "Definition published successfully.")
    |> redirect(
      to:
        Routes.workspace_definition_path(
          conn,
          :show,
          workspace_id,
          definition
        )
    )
  end
end

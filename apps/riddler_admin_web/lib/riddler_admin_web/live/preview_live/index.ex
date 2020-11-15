defmodule RiddlerAdminWeb.PreviewLive.Index do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.Previews
  alias RiddlerAdmin.Previews.Preview

  @impl true
  def mount(%{"workspace_id" => workspace_id}, _session, socket) do
    {:ok, assign(socket, previews: list_previews(), workspace_id: workspace_id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    preview = Previews.get_preview!(id)

    socket
    |> assign(:page_title, "Edit Preview")
    |> assign(:preview, %Preview{
      preview
      | context_overrides: Ymlr.document!(preview.context_overrides)
    })
    |> assign_dropdowns()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Preview")
    |> assign(:preview, %Preview{})
    |> assign_dropdowns()
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Previews")
    |> assign(:preview, nil)
    |> assign(:previews, list_previews())
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    preview = Previews.get_preview!(id)
    {:ok, _} = Previews.delete_preview(preview)

    {:noreply, assign(socket, :previews, list_previews())}
  end

  defp assign_dropdowns(%{assigns: %{workspace_id: workspace_id}} = socket) do
    definitions = Definitions.list_workspace_definitions(workspace_id)
    preview_contexts = Previews.list_workspace_preview_contexts(workspace_id)

    socket
    |> assign(:definitions, definitions)
    |> assign(:preview_contexts, preview_contexts)
  end

  defp list_previews do
    Previews.list_previews()
  end
end

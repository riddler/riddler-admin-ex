defmodule RiddlerAdminWeb.PreviewLive.Show do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Previews

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "workspace_id" => workspace_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:preview, Previews.get_preview!(id))
     |> assign(:workspace_id, workspace_id)}
  end

  defp page_title(:show), do: "Show Preview"
  defp page_title(:edit), do: "Edit Preview"
end

defmodule RiddlerAdminWeb.PreviewLive.FormComponent do
  use RiddlerAdminWeb, :live_component

  alias RiddlerAdmin.Previews

  @impl true
  def update(%{preview: preview} = assigns, socket) do
    changeset = Previews.change_preview(preview)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"preview" => %{"context_overrides" => context_overrides} = preview_params},
        socket
      ) do
    changeset =
      socket.assigns.preview
      |> Previews.change_preview(%{
        preview_params
        | "context_overrides" => YamlElixir.read_from_string!(context_overrides)
      })
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"preview" => preview_params}, socket) do
    save_preview(socket, socket.assigns.action, preview_params)
  end

  defp save_preview(socket, :edit, %{"context_overrides" => context_overrides} = preview_params) do
    case Previews.update_preview(socket.assigns.preview, %{
           preview_params
           | "context_overrides" => YamlElixir.read_from_string!(context_overrides)
         }) do
      {:ok, _preview} ->
        {:noreply,
         socket
         |> put_flash(:info, "Preview updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_preview(
         %{assigns: %{workspace_id: workspace_id}} = socket,
         :new,
         %{"context_overrides" => context_overrides} = preview_params
       ) do
    case Previews.create_preview(
           %{
             preview_params
             | "context_overrides" => YamlElixir.read_from_string!(context_overrides)
           },
           workspace_id
         ) do
      {:ok, _preview} ->
        {:noreply,
         socket
         |> put_flash(:info, "Preview created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

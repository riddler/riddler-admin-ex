defmodule RiddlerAdminWeb.WorkspaceLive.Settings do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    workspace = socket.assigns.current_scope.workspace
    changeset = Workspace.changeset(workspace, %{})

    {:ok,
     socket
     |> assign(:page_title, "#{workspace.name} Settings")
     |> assign(:workspace, workspace)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"workspace" => workspace_params}, socket) do
    workspace = socket.assigns.current_scope.workspace

    changeset =
      workspace
      |> Workspace.changeset(workspace_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"workspace" => workspace_params}, socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    case Workspaces.update_workspace(current_scope, workspace, workspace_params) do
      {:ok, updated_workspace} ->
        {:noreply,
         socket
         |> assign(:workspace, updated_workspace)
         |> put_flash(:info, "Workspace updated successfully!")
         |> assign_form(Workspace.changeset(updated_workspace, %{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    case Workspaces.delete_workspace(current_scope, workspace) do
      {:ok, _workspace} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workspace deleted successfully.")
         |> push_navigate(to: ~p"/workspaces")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Unable to delete workspace.")
         |> push_patch(to: ~p"/workspaces/#{workspace.slug}/settings")}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="flex justify-between items-start">
          <div>
            <.header>
              {@workspace.name} Settings
              <:subtitle>Manage your workspace configuration</:subtitle>
            </.header>
          </div>
          <.link
            navigate={~p"/workspaces/#{@workspace.slug}"}
            class="btn btn-outline"
          >
            <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Back to Dashboard
          </.link>
        </div>

    <!-- General Settings -->
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-cog-6-tooth" class="w-5 h-5" /> General Settings
            </h2>

            <.form
              for={@form}
              id="workspace-settings-form"
              phx-change="validate"
              phx-submit="save"
            >
              <div class="space-y-4">
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Workspace Name"
                  required
                />

                <.input
                  field={@form[:slug]}
                  type="text"
                  label="Workspace Slug"
                  required
                />
              </div>

              <div class="card-actions justify-end mt-6">
                <.button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
                  <.icon name="hero-check" class="w-4 h-4 mr-2" /> Save Changes
                </.button>
              </div>
            </.form>
          </div>
        </div>

    <!-- Quick Actions -->
        <div class="space-y-4">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">
                <.icon name="hero-users" class="w-5 h-5" /> Team Management
              </h2>
              <p class="text-sm">Manage workspace members and permissions.</p>
              <div class="card-actions justify-end">
                <.link
                  navigate={~p"/workspaces/#{@workspace.slug}/settings/members"}
                  class="btn btn-primary"
                >
                  Manage Members
                </.link>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">
                <.icon name="hero-user-plus" class="w-5 h-5" /> Invite Members
              </h2>
              <p class="text-sm">Invite new team members to join this workspace.</p>
              <div class="card-actions justify-end">
                <.link
                  navigate={~p"/workspaces/#{@workspace.slug}/settings/members/invite"}
                  class="btn btn-success"
                >
                  Send Invites
                </.link>
              </div>
            </div>
          </div>
        </div>

    <!-- Danger Zone -->
        <div class="divider">Danger Zone</div>

        <div class="card bg-error/10 border border-error/20 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-error">
              <.icon name="hero-exclamation-triangle" class="w-5 h-5" /> Delete Workspace
            </h2>
            <p class="text-sm">
              Permanently delete this workspace and all associated data. This action cannot be undone.
            </p>
            <div class="card-actions justify-end">
              <button
                type="button"
                class="btn btn-error"
                onclick="delete_workspace_modal.showModal()"
              >
                <.icon name="hero-trash" class="w-4 h-4 mr-2" /> Delete Workspace
              </button>
            </div>
          </div>
        </div>

    <!-- Delete Confirmation Modal -->
        <dialog id="delete_workspace_modal" class="modal">
          <div class="modal-box">
            <h3 class="font-bold text-lg text-error">Delete Workspace</h3>
            <p class="py-4">
              Are you sure you want to delete <strong>{@workspace.name}</strong>?
              This will permanently remove the workspace and all associated data.
            </p>
            <div class="modal-action">
              <button type="button" class="btn" onclick="delete_workspace_modal.close()">
                Cancel
              </button>
              <button
                type="button"
                class="btn btn-error"
                phx-click="delete"
                onclick="delete_workspace_modal.close()"
              >
                <.icon name="hero-trash" class="w-4 h-4 mr-2" /> Delete Forever
              </button>
            </div>
          </div>
          <form method="dialog" class="modal-backdrop">
            <button>close</button>
          </form>
        </dialog>
      </div>
    </Layouts.app>
    """
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

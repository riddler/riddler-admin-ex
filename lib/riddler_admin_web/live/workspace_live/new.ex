defmodule RiddlerAdminWeb.WorkspaceLive.New do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Workspace.changeset(%Workspace{}, %{})

    {:ok,
     socket
     |> assign(:page_title, "Create Workspace")
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"workspace" => workspace_params}, socket) do
    changeset =
      %Workspace{}
      |> Workspace.changeset(workspace_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"workspace" => workspace_params}, socket) do
    current_scope = socket.assigns.current_scope

    case Workspaces.create_workspace(current_scope, workspace_params) do
      {:ok, workspace} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workspace created successfully!")
         |> push_navigate(to: ~p"/workspaces/#{workspace}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="text-center">
          <.header>
            Create Workspace
            <:subtitle>Set up a new workspace for your team</:subtitle>
          </.header>
        </div>

        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <.form
              for={@form}
              id="workspace-form"
              phx-change="validate"
              phx-submit="save"
            >
              <div class="space-y-4">
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Workspace Name"
                  placeholder="Marketing"
                  required
                />

                <.input
                  field={@form[:slug]}
                  type="text"
                  label="Workspace Slug"
                  placeholder="marketing"
                  required
                />
              </div>

              <div class="card-actions justify-end mt-6">
                <.link navigate={~p"/workspaces"} class="btn btn-outline">
                  Cancel
                </.link>
                <.button type="submit" class="btn btn-primary" phx-disable-with="Creating...">
                  <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Create Workspace
                </.button>
              </div>
            </.form>
          </div>
        </div>

        <div class="alert alert-info">
          <.icon name="hero-information-circle" class="w-5 h-5" />
          <div>
            <h3 class="font-bold">Getting Started</h3>
            <div class="text-sm">
              Once created, you'll be the admin of this workspace and can invite team members.
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

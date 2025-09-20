defmodule RiddlerAdminWeb.WorkspaceLive.Index do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user
    workspaces = Workspaces.list_workspaces_for_user(current_user)

    {:ok,
     socket
     |> assign(:page_title, "Your Workspaces")
     |> assign(:workspaces, workspaces)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="text-center">
          <.header>
            Your Workspaces
            <:subtitle>Select a workspace to continue or create a new one.</:subtitle>
          </.header>
        </div>

        <div class="flex justify-center">
          <.link
            navigate={~p"/workspaces/new"}
            class="btn btn-primary"
          >
            <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Create workspace
          </.link>
        </div>

        <div :if={@workspaces == []} class="text-center py-12">
          <div class="mx-auto w-24 h-24 rounded-full bg-base-200 flex items-center justify-center mb-6">
            <.icon name="hero-building-office" class="w-12 h-12 text-base-content/50" />
          </div>
          <h3 class="text-lg font-semibold">No workspaces yet</h3>
          <p class="mt-2 text-sm text-base-content/70 max-w-sm mx-auto">
            Get started by creating your first workspace to organize your work and collaborate with your team.
          </p>
          <div class="mt-8">
            <.link
              navigate={~p"/workspaces/new"}
              class="btn btn-primary btn-lg"
            >
              <.icon name="hero-plus" class="w-5 h-5 mr-2" /> Create your first workspace
            </.link>
          </div>
        </div>

        <div :if={@workspaces != []} class="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div
            :for={workspace <- @workspaces}
            class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow duration-200"
          >
            <div class="card-body">
              <div class="flex items-center gap-4">
                <div class="avatar placeholder">
                  <div class="bg-primary text-primary-content rounded-full w-12">
                    <.icon name="hero-building-office" class="w-6 h-6" />
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="card-title">
                    <.link
                      navigate={~p"/workspaces/#{workspace}"}
                      class="link link-hover"
                    >
                      {workspace.name}
                    </.link>
                  </h3>
                  <p class="text-sm text-base-content/70 font-mono">
                    /{workspace.slug}
                  </p>
                </div>
                <.icon name="hero-arrow-top-right-on-square" class="w-5 h-5 text-base-content/50" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

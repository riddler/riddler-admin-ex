defmodule RiddlerAdminWeb.UserLive.Dashboard do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user
    workspaces = Workspaces.list_workspaces_for_user(current_user)

    # Redirect to workspace selection if user has workspaces
    # or to workspace creation if they don't
    case workspaces do
      [] ->
        {:ok,
         socket
         |> put_flash(:info, "Welcome! Let's create your first workspace.")
         |> push_navigate(to: ~p"/workspaces/new")}

      [workspace] ->
        # If user has only one workspace, redirect to it
        {:ok,
         socket
         |> push_navigate(to: ~p"/workspaces/#{workspace}")}

      _multiple_workspaces ->
        # If user has multiple workspaces, show selection page
        {:ok,
         socket
         |> push_navigate(to: ~p"/workspaces")}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.icon name="hero-arrow-path" class="mx-auto h-12 w-12 text-base-content/50 animate-spin" />
          <h3 class="mt-2 text-sm font-semibold">Redirecting...</h3>
          <p class="mt-1 text-sm text-base-content/70">
            Taking you to your workspace
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

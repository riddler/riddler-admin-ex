defmodule RiddlerAdminWeb.WorkspaceLive.Dashboard do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    {:ok, memberships} = Workspaces.list_memberships(current_scope, workspace)

    {:ok,
     socket
     |> assign(:page_title, workspace.name)
     |> assign(:workspace, workspace)
     |> assign(:memberships, memberships)
     |> assign(:member_count, length(memberships))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="flex justify-between items-start">
          <div>
            <.header>
              {@workspace.name}
              <:subtitle>Workspace Dashboard</:subtitle>
            </.header>
          </div>
          <div class="flex gap-2">
            <.link
              navigate={~p"/workspaces/#{@workspace}/settings"}
              class="btn btn-outline"
            >
              <.icon name="hero-cog-6-tooth" class="w-4 h-4 mr-2" /> Settings
            </.link>
          </div>
        </div>

    <!-- Members Preview -->
        <div class="space-y-4">
          <div class="flex justify-between items-center">
            <div>
              <.header>
                Recent Members
                <:subtitle>Members of this workspace</:subtitle>
              </.header>
            </div>
            <.link
              navigate={~p"/workspaces/#{@workspace}/settings/members"}
              class="btn btn-primary"
            >
              <.icon name="hero-users" class="w-4 h-4 mr-2" /> View all
            </.link>
          </div>

          <div class="card bg-base-100 shadow-xl">
            <div class="card-body p-0">
              <div class="overflow-x-auto">
                <table class="table">
                  <thead>
                    <tr>
                      <th>Member</th>
                      <th>Role</th>
                      <th>Member Since</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr :for={membership <- Enum.take(@memberships, 5)} class="hover">
                      <td>
                        <div class="flex items-center gap-3">
                          <div class="avatar placeholder">
                            <div class="bg-primary text-primary-content rounded-full w-8">
                              <span class="text-xs">
                                {String.upcase(String.first(membership.user.email))}
                              </span>
                            </div>
                          </div>
                          <div>
                            <div class="font-medium">{membership.user.email}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        <div class={[
                          "badge",
                          if(membership.role == :admin, do: "badge-primary", else: "badge-neutral")
                        ]}>
                          {String.capitalize(to_string(membership.role))}
                        </div>
                      </td>
                      <td class="text-sm text-base-content/70">
                        {Calendar.strftime(membership.inserted_at, "%b %Y")}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

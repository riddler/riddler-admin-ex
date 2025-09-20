defmodule RiddlerAdminWeb.WorkspaceLive.Members do
  use RiddlerAdminWeb, :live_view

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Membership

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    {:ok, memberships} = Workspaces.list_memberships(current_scope, workspace)

    {:ok,
     socket
     |> assign(:page_title, "#{workspace.name} Members")
     |> assign(:workspace, workspace)
     |> assign(:memberships, memberships)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "#{socket.assigns.current_scope.workspace.name} Members")
  end

  defp apply_action(socket, :edit_member, %{"id" => membership_id}) do
    workspace = socket.assigns.current_scope.workspace
    _current_user = socket.assigns.current_scope.user

    # Get membership by finding it in the list
    {:ok, memberships} = Workspaces.list_memberships(socket.assigns.current_scope, workspace)

    case Enum.find(memberships, &(&1.id == membership_id)) do
      membership when not is_nil(membership) ->
        changeset = Membership.changeset(membership, %{})

        socket
        |> assign(:page_title, "Edit Member")
        |> assign(:editing_membership, membership)
        |> assign(:member_form, to_form(changeset))

      nil ->
        socket
        |> put_flash(:error, "Member not found.")
        |> push_navigate(to: ~p"/workspaces/#{workspace.slug}/settings/members")
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate_member", %{"membership" => membership_params}, socket) do
    membership = socket.assigns.editing_membership

    changeset =
      membership
      |> Membership.changeset(membership_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset)
    {:noreply, assign(socket, :member_form, form)}
  end

  def handle_event("update_member", %{"membership" => membership_params}, socket) do
    membership = socket.assigns.editing_membership
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    case Workspaces.update_membership(current_scope, membership, membership_params) do
      {:ok, _updated_membership} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully!")
         |> push_navigate(to: ~p"/workspaces/#{workspace.slug}/settings/members")
         |> refresh_memberships()}

      {:error, changeset} ->
        form = to_form(changeset)
        {:noreply, assign(socket, :member_form, form)}
    end
  end

  def handle_event("remove_member", %{"membership-id" => membership_id}, socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    # Find membership in the current list
    {:ok, memberships} = Workspaces.list_memberships(current_scope, workspace)

    case Enum.find(memberships, &(&1.id == membership_id)) do
      membership when not is_nil(membership) ->
        case Workspaces.delete_membership(current_scope, membership) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Member removed successfully.")
             |> refresh_memberships()}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Unable to remove member.")
             |> refresh_memberships()}
        end

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Member not found.")
         |> refresh_memberships()}
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
              {@workspace.name} Members
              <:subtitle>Manage workspace members and permissions</:subtitle>
            </.header>
          </div>
          <div class="flex gap-2">
            <.link
              navigate={~p"/workspaces/#{@workspace.slug}/settings"}
              class="btn btn-outline"
            >
              <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Back to Settings
            </.link>
          </div>
        </div>

        <div :if={@live_action == :edit_member} class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-user-circle" class="w-5 h-5" />
              Edit Member: {@editing_membership.user.email}
            </h2>

            <.form
              for={@member_form}
              id="member-form"
              phx-change="validate_member"
              phx-submit="update_member"
            >
              <div class="space-y-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Role</span>
                  </label>
                  <select class="select select-bordered" name="membership[role]">
                    <option value="member" selected={@editing_membership.role == :member}>
                      Member
                    </option>
                    <option value="admin" selected={@editing_membership.role == :admin}>
                      Admin
                    </option>
                  </select>
                  <label class="label">
                    <span class="label-text-alt">
                      Admins can manage workspace settings and members
                    </span>
                  </label>
                </div>
              </div>

              <div class="card-actions justify-end mt-6">
                <.link
                  navigate={~p"/workspaces/#{@workspace.slug}/settings/members"}
                  class="btn btn-outline"
                >
                  Cancel
                </.link>
                <.button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
                  <.icon name="hero-check" class="w-4 h-4 mr-2" /> Save Changes
                </.button>
              </div>
            </.form>
          </div>
        </div>

        <div :if={@live_action == :index} class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <div class="flex justify-between items-center mb-4">
              <h2 class="card-title">
                <.icon name="hero-users" class="w-5 h-5" /> Members ({length(@memberships)})
              </h2>
            </div>

            <div class="overflow-x-auto">
              <table class="table table-zebra">
                <thead>
                  <tr>
                    <th>Member</th>
                    <th>Role</th>
                    <th>Joined</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={membership <- @memberships}>
                    <td>
                      <div class="flex items-center gap-3">
                        <div class="avatar placeholder">
                          <div class="bg-primary text-primary-content rounded-full w-10">
                            <span class="text-sm">
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
                      {Calendar.strftime(membership.inserted_at, "%b %d, %Y")}
                    </td>
                    <td>
                      <div class="flex gap-2">
                        <.link
                          navigate={~p"/workspaces/#{@workspace.slug}/members/#{membership.id}/edit"}
                          class="btn btn-sm btn-outline"
                        >
                          <.icon name="hero-pencil" class="w-3 h-3" />
                        </.link>
                        <button
                          type="button"
                          class="btn btn-sm btn-outline btn-error"
                          phx-click="remove_member"
                          phx-value-membership-id={membership.id}
                          data-confirm="Are you sure you want to remove this member?"
                        >
                          <.icon name="hero-trash" class="w-3 h-3" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>

            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp refresh_memberships(socket) do
    workspace = socket.assigns.current_scope.workspace
    current_scope = socket.assigns.current_scope

    {:ok, memberships} = Workspaces.list_memberships(current_scope, workspace)
    assign(socket, :memberships, memberships)
  end
end

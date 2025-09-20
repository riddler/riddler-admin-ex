defmodule RiddlerAdmin.Authorization do
  @moduledoc """
  Authorization policies for workspace-based access control.

  This module defines the authorization rules for workspaces and memberships
  using the Bodyguard library. Policies are based on workspace membership
  roles and sysadmin privileges.
  """

  @behaviour Bodyguard.Policy

  alias RiddlerAdmin.Accounts.User
  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.{Membership, Workspace}

  # Sysadmins can perform any action on any resource
  @spec authorize(atom(), User.t(), any()) :: :ok | :error
  def authorize(_action, %User{sysadmin: true}, _resource), do: :ok

  # =============================================================================
  # Workspace Policies
  # =============================================================================

  # Any authenticated user can create workspaces
  def authorize(:create_workspace, %User{}, %Workspace{}), do: :ok

  # Workspace members can read/view workspaces
  def authorize(:read_workspace, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.member?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can update workspaces
  def authorize(:update_workspace, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can delete workspaces
  def authorize(:delete_workspace, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can manage workspaces (settings, members, etc.)
  def authorize(:manage_workspace, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # =============================================================================
  # Membership Policies
  # =============================================================================

  # Workspace members can list memberships in their workspace
  def authorize(:list_memberships, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.member?(user, workspace), do: :ok, else: :error
  end

  # Workspace members can view individual memberships in their workspace
  def authorize(:read_membership, %User{} = user, %Membership{workspace_id: workspace_id}) do
    workspace = Workspaces.get_workspace!(workspace_id)
    if Workspaces.member?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can create memberships (invite users)
  def authorize(:create_membership, %User{} = user, %Workspace{} = workspace) do
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can update memberships (change roles)
  def authorize(:update_membership, %User{} = user, %Membership{workspace_id: workspace_id}) do
    workspace = Workspaces.get_workspace!(workspace_id)
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # Workspace admins can delete memberships (remove users)
  def authorize(:delete_membership, %User{} = user, %Membership{workspace_id: workspace_id}) do
    workspace = Workspaces.get_workspace!(workspace_id)
    if Workspaces.admin?(user, workspace), do: :ok, else: :error
  end

  # Default deny - if no rule matches, deny access
  def authorize(_action, _user, _resource), do: :error

  @doc """
  Checks if a user can access a workspace (is member or sysadmin).
  """
  @spec can_access_workspace?(User.t(), Workspace.t()) :: boolean()
  def can_access_workspace?(%User{} = user, %Workspace{} = workspace) do
    case authorize(:read_workspace, user, workspace) do
      :ok -> true
      :error -> false
    end
  end

  @doc """
  Checks if a user is a sysadmin.
  """
  @spec sysadmin?(User.t()) :: boolean()
  def sysadmin?(%User{sysadmin: true}), do: true
  def sysadmin?(%User{}), do: false
end

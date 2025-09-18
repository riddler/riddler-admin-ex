defmodule RiddlerAdmin.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `RiddlerAdmin.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias RiddlerAdmin.Accounts.User
  alias RiddlerAdmin.Workspaces.Workspace

  defstruct user: nil, workspace: nil

  @type t :: %__MODULE__{user: User.t() | nil, workspace: Workspace.t() | nil}

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  @spec for_user(User.t()) :: t()
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  @spec for_user(nil) :: nil
  def for_user(nil), do: nil

  @doc """
  Creates a scope for the given user and workspace.
  """
  @spec for_user_and_workspace(User.t(), Workspace.t()) :: t()
  def for_user_and_workspace(%User{} = user, %Workspace{} = workspace) do
    %__MODULE__{user: user, workspace: workspace}
  end

  @doc """
  Adds a workspace to an existing scope.
  """
  @spec with_workspace(t(), Workspace.t()) :: t()
  def with_workspace(%__MODULE__{} = scope, %Workspace{} = workspace) do
    %{scope | workspace: workspace}
  end

  @doc """
  Checks if the scope has a sysadmin user.
  """
  @spec sysadmin?(t()) :: boolean()
  def sysadmin?(%__MODULE__{user: %User{sysadmin: true}}), do: true
  def sysadmin?(%__MODULE__{}), do: false

  @doc """
  Checks if the scope has a workspace.
  """
  @spec has_workspace?(t()) :: boolean()
  def has_workspace?(%__MODULE__{workspace: %Workspace{}}), do: true
  def has_workspace?(%__MODULE__{}), do: false
end

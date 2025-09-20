defmodule RiddlerAdmin.Workspaces do
  @moduledoc """
  The Workspaces context for managing workspaces and memberships.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias RiddlerAdmin.Accounts.{Scope, User}
  alias RiddlerAdmin.Authorization
  alias RiddlerAdmin.Repo
  alias RiddlerAdmin.Workspaces.{Membership, Workspace}

  ## Workspace functions

  @doc """
  Returns the list of workspaces.
  """
  @spec list_workspaces() :: [Workspace.t()]
  def list_workspaces do
    Repo.all(Workspace)
  end

  @doc """
  Returns the list of workspaces for a given user.
  """
  @spec list_workspaces_for_user(User.t()) :: [Workspace.t()]
  def list_workspaces_for_user(%User{} = user) do
    from(w in Workspace,
      join: m in Membership,
      on: m.workspace_id == w.id,
      where: m.user_id == ^user.id,
      order_by: w.name
    )
    |> Repo.all()
  end

  @doc """
  Gets a single workspace by ID.

  Raises `Ecto.NoResultsError` if the Workspace does not exist.
  """
  @spec get_workspace!(String.t()) :: Workspace.t()
  def get_workspace!(id), do: Repo.get!(Workspace, id)

  @doc """
  Gets a single workspace by slug.

  Returns `nil` if the Workspace does not exist.
  """
  @spec get_workspace_by_slug(String.t()) :: Workspace.t() | nil
  def get_workspace_by_slug(slug) when is_binary(slug) do
    Repo.get_by(Workspace, slug: slug)
  end

  @doc """
  Gets a single workspace by slug.

  Raises `Ecto.NoResultsError` if the Workspace does not exist.
  """
  @spec get_workspace_by_slug!(String.t()) :: Workspace.t()
  def get_workspace_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Workspace, slug: slug)
  end

  @doc """
  Creates a workspace and adds the creator as an admin.
  """
  @spec create_workspace(Scope.t(), map()) ::
          {:ok, Workspace.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_workspace(%Scope{user: user}, attrs \\ %{}) do
    workspace = %Workspace{}

    case Bodyguard.permit(Authorization, :create_workspace, user, workspace) do
      :ok ->
        workspace_changeset = Workspace.changeset(workspace, attrs)

        Multi.new()
        |> Multi.insert(:workspace, workspace_changeset)
        |> Multi.run(:membership, fn _repo, %{workspace: workspace} ->
          create_membership_internal(user, workspace, :admin)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{workspace: workspace}} -> {:ok, workspace}
          {:error, :workspace, changeset, _changes} -> {:error, changeset}
          {:error, :membership, changeset, _changes} -> {:error, changeset}
        end

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Updates a workspace.
  """
  @spec update_workspace(Scope.t(), Workspace.t(), map()) ::
          {:ok, Workspace.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_workspace(%Scope{user: user}, %Workspace{} = workspace, attrs) do
    case Bodyguard.permit(Authorization, :update_workspace, user, workspace) do
      :ok ->
        workspace
        |> Workspace.changeset(attrs)
        |> Repo.update()

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a workspace.
  """
  @spec delete_workspace(Scope.t(), Workspace.t()) ::
          {:ok, Workspace.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_workspace(%Scope{user: user}, %Workspace{} = workspace) do
    case Bodyguard.permit(Authorization, :delete_workspace, user, workspace) do
      :ok ->
        Repo.delete(workspace)

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workspace changes.
  """
  @spec change_workspace(Workspace.t(), map()) :: Ecto.Changeset.t()
  def change_workspace(%Workspace{} = workspace, attrs \\ %{}) do
    Workspace.changeset(workspace, attrs)
  end

  ## Membership functions

  @doc """
  Returns the list of memberships for a workspace.
  """
  @spec list_memberships(Scope.t(), Workspace.t()) ::
          {:ok, [Membership.t()]} | {:error, :unauthorized}
  def list_memberships(%Scope{user: user}, %Workspace{} = workspace) do
    case Bodyguard.permit(Authorization, :list_memberships, user, workspace) do
      :ok ->
        memberships =
          from(m in Membership,
            where: m.workspace_id == ^workspace.id,
            preload: [:user]
          )
          |> Repo.all()

        {:ok, memberships}

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Gets a user's membership in a workspace.
  """
  @spec get_membership(User.t(), Workspace.t()) :: Membership.t() | nil
  def get_membership(%User{} = user, %Workspace{} = workspace) do
    Repo.get_by(Membership, user_id: user.id, workspace_id: workspace.id)
  end

  @doc """
  Gets a user's membership in a workspace by slug.
  """
  @spec get_membership_by_slug(User.t(), String.t()) :: Membership.t() | nil
  def get_membership_by_slug(%User{} = user, workspace_slug) when is_binary(workspace_slug) do
    from(m in Membership,
      join: w in Workspace,
      on: m.workspace_id == w.id,
      where: m.user_id == ^user.id and w.slug == ^workspace_slug,
      preload: [workspace: w]
    )
    |> Repo.one()
  end

  @doc """
  Creates a membership.
  """
  @spec create_membership(Scope.t(), User.t(), Workspace.t(), atom()) ::
          {:ok, Membership.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_membership(%Scope{user: scope_user}, %User{} = user, %Workspace{} = workspace, role)
      when role in [:admin, :member] do
    case Bodyguard.permit(Authorization, :create_membership, scope_user, workspace) do
      :ok ->
        create_membership_internal(user, workspace, role)

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  # Internal function for creating memberships without authorization checks
  @spec create_membership_internal(User.t(), Workspace.t(), atom()) ::
          {:ok, Membership.t()} | {:error, Ecto.Changeset.t()}
  defp create_membership_internal(%User{} = user, %Workspace{} = workspace, role)
       when role in [:admin, :member] do
    %Membership{}
    |> Membership.changeset(%{
      user_id: user.id,
      workspace_id: workspace.id,
      role: role
    })
    |> Repo.insert()
  end

  @doc """
  Updates a membership.
  """
  @spec update_membership(Scope.t(), Membership.t(), map()) ::
          {:ok, Membership.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_membership(%Scope{user: user}, %Membership{} = membership, attrs) do
    case Bodyguard.permit(Authorization, :update_membership, user, membership) do
      :ok ->
        membership
        |> Membership.changeset(attrs)
        |> Repo.update()

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a membership.
  """
  @spec delete_membership(Scope.t(), Membership.t()) ::
          {:ok, Membership.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_membership(%Scope{user: user}, %Membership{} = membership) do
    case Bodyguard.permit(Authorization, :delete_membership, user, membership) do
      :ok ->
        Repo.delete(membership)

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.
  """
  @spec change_membership(Membership.t(), map()) :: Ecto.Changeset.t()
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end

  ## Authorization helpers

  @doc """
  Checks if a user is a member of a workspace.
  """
  @spec member?(User.t(), Workspace.t()) :: boolean()
  def member?(%User{} = user, %Workspace{} = workspace) do
    not is_nil(get_membership(user, workspace))
  end

  @doc """
  Checks if a user is an admin of a workspace.
  """
  @spec admin?(User.t(), Workspace.t()) :: boolean()
  def admin?(%User{} = user, %Workspace{} = workspace) do
    case get_membership(user, workspace) do
      %Membership{role: :admin} -> true
      _membership -> false
    end
  end

  @doc """
  Checks if a user can access a workspace (either member/admin or sysadmin).
  """
  @spec can_access?(User.t(), Workspace.t()) :: boolean()
  def can_access?(%User{sysadmin: true}, %Workspace{}), do: true
  def can_access?(%User{} = user, %Workspace{} = workspace), do: member?(user, workspace)
end

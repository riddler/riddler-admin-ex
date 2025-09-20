defmodule RiddlerAdmin.Workspaces.Membership do
  @moduledoc """
  Membership schema representing the relationship between users and workspaces.
  """
  use RiddlerAdmin.Schema, prefix: "mem", size: :small
  import Ecto.Changeset

  alias RiddlerAdmin.Accounts.User
  alias RiddlerAdmin.Workspaces.Workspace

  @roles [:admin, :member]

  typed_schema "workspace_memberships" do
    field :role, Ecto.Enum, values: @roles

    belongs_to :user, User, type: :string
    belongs_to :workspace, Workspace, type: :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  A membership changeset for creation and updates.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :user_id, :workspace_id])
    |> validate_required([:role, :user_id, :workspace_id])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:user_id, :workspace_id],
      message: "User is already a member of this workspace"
    )
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:workspace_id)
  end

  @doc """
  Returns the list of available roles.
  """
  @spec roles() :: [atom()]
  def roles, do: @roles

  @doc """
  Checks if the given role is an admin role.
  """
  @spec admin?(atom()) :: boolean()
  def admin?(:admin), do: true
  def admin?(_role), do: false

  @doc """
  Checks if the given role is a member role.
  """
  @spec member?(atom()) :: boolean()
  def member?(:member), do: true
  def member?(_role), do: false
end

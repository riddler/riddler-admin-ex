defmodule RiddlerAdmin.Workspaces.Workspace do
  @moduledoc """
  Workspace schema representing a tenant in the multi-workspace system.
  """
  use RiddlerAdmin.Schema, prefix: "wks", rand_size: 1
  import Ecto.Changeset

  alias RiddlerAdmin.Workspaces.Membership

  typed_schema "workspaces" do
    field :name, :string
    field :slug, :string

    has_many :memberships, Membership, foreign_key: :workspace_id
    has_many :users, through: [:memberships, :user]

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  A workspace changeset for creation and updates.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    )
    |> validate_length(:slug, min: 2, max: 50)
    |> unique_constraint(:slug)
  end

  @doc """
  Generates a slug from a workspace name.
  """
  @spec generate_slug(String.t()) :: String.t()
  def generate_slug(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end

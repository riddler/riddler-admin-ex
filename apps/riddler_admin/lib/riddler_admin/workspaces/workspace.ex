defmodule RiddlerAdmin.Workspaces.Workspace do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Conditions.Condition
  alias RiddlerAdmin.Flags.Flag

  @derive {Jason.Encoder, only: [:id, :name, :conditions, :flags]}
  schema "workspaces" do
    field :id, Ecto.UXID, primary_key: true, autogenerate: true, prefix: "wsp", rand_size: 2
    field :name, :string
    field :key, :string
    field :account_id, Ecto.UXID
    field :owner_identity_id, Ecto.UXID

    has_many :conditions, Condition, references: :id
    has_many :flags, Flag, references: :id

    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :key])
    |> put_key_change()
    |> validate_required([:name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
  end

  @doc false
  def with_account_and_owner_changeset(account, attrs, account_id, owner_id) do
    account
    |> changeset(attrs)
    |> put_change(:account_id, account_id)
    |> put_change(:owner_identity_id, owner_id)
    |> validate_required([:account_id, :owner_identity_id])
  end

  defp put_key_change(%{data: %{key: nil}, changes: %{name: name}} = changeset)
       when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_]/, "_")
      |> String.replace(~r/_+/, "_")

    changeset
    |> put_change(:key, key)
  end

  defp put_key_change(changeset), do: changeset
end

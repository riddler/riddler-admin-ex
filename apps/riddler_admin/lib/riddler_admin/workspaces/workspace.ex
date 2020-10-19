defmodule RiddlerAdmin.Workspaces.Workspace do
  use RiddlerAdmin.Schema

  schema "workspaces" do
    field :id, Ecto.UXID, primary_key: true, autogenerate: true, prefix: "wsp", rand_size: 5
    field :name, :string
    field :account_id, Ecto.UXID
    field :owner_identity_id, Ecto.UXID

    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc false
  def with_account_and_owner_changeset(account, attrs, account_id, owner_id) do
    account
    |> changeset(attrs)
    |> put_change(:account_id, account_id)
    |> put_change(:owner_identity_id, owner_id)
    |> validate_required([:account_id, :owner_identity_id])
  end
end

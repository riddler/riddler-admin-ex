defmodule RiddlerAdmin.Accounts.Account do
  use RiddlerAdmin.Schema

  schema "accounts" do
    field :id, UXID, primary_key: true, autogenerate: true, prefix: "acc", size: :small
    field :name, :string
    field :owner_identity_id, UXID

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc false
  def with_owner_changeset(account, attrs, owner_id) do
    account
    |> changeset(attrs)
    |> put_change(:owner_identity_id, owner_id)
    |> validate_required([:owner_identity_id])
  end
end

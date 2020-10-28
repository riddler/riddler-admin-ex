defmodule RiddlerAdmin.Flags.Flag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "flags" do
    field :key, :string
    field :type, :string
    field :workspace_id, :id

    timestamps()
  end

  @doc false
  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [:key, :type])
    |> validate_required([:key, :type])
  end
end

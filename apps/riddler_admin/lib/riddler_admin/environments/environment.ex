defmodule RiddlerAdmin.Environments.Environment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "environments" do
    field :key, :string
    field :name, :string
    field :workspace_id, :id

    timestamps()
  end

  @doc false
  def changeset(environment, attrs) do
    environment
    |> cast(attrs, [:name, :key])
    |> validate_required([:name, :key])
  end
end

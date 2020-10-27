defmodule RiddlerAdmin.Definitions.Definition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "definitions" do
    field :data, :map
    field :schema_version, :integer
    field :version, :integer
    field :workspace_id, :id
    field :publish_request_id, :id

    timestamps()
  end

  @doc false
  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [:version, :schema_version, :data])
    |> validate_required([:version, :schema_version, :data])
  end
end

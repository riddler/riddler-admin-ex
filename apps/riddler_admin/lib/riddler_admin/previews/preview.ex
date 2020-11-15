defmodule RiddlerAdmin.Previews.Preview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "previews" do
    field :workspace_id, :id
    field :definition_id, :id

    timestamps()
  end

  @doc false
  def changeset(preview, attrs) do
    preview
    |> cast(attrs, [])
    |> validate_required([])
  end
end

defmodule RiddlerAdmin.Previews.Preview do
  use RiddlerAdmin.Schema

  @id_opts [prefix: "prectx", rand_size: 2]

  schema "previews" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :name, :string
    field :context_overrides, :map

    belongs_to :workspace, RiddlerAdmin.Workspaces.Workspace
    belongs_to :definition, RiddlerAdmin.Definitions.Definition

    timestamps()
  end

  def create_changeset(preview, attrs, workspace_id) do
    preview
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
  end

  @doc false
  def changeset(preview, attrs) do
    preview
    |> cast(attrs, [:name, :context_overrides])
    |> validate_required([:name])
  end
end

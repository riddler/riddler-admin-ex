defmodule RiddlerAdmin.Previews.PreviewContext do
  use RiddlerAdmin.Schema

  @id_opts [prefix: "prectx", rand_size: 2]

  schema "preview_contexts" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :name, :string
    field :data, :map

    belongs_to :workspace, RiddlerAdmin.Workspaces.Workspace

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(preview_context, attrs, workspace_id) do
    preview_context
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
  end

  @doc false
  def changeset(preview_context, attrs) do
    preview_context
    |> cast(attrs, [:name, :data])
    |> validate_required([:name, :data])
  end
end
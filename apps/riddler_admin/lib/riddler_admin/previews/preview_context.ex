defmodule RiddlerAdmin.Previews.PreviewContext do
  use RiddlerAdmin.Schema, id_prefix: "prectx"

  schema "preview_contexts" do
    field :name, :string
    field :data, :map

    belongs_to :workspace, RiddlerAdmin.Workspaces.Workspace

    timestamps()
  end

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

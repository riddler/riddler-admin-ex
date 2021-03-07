defmodule RiddlerAdmin.Definitions.Definition do
  use RiddlerAdmin.Schema, id_prefix: "def"

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  @current_schema_version 1

  @derive {Jason.Encoder, only: [:id, :schema_version, :version, :workspace_id]}
  schema "definitions" do
    field :schema_version, :integer, null: false
    field :version, :integer, null: false
    field :label, :string, null: false

    field :data, :map, null: false
    field :yaml, :string, null: false

    belongs_to :workspace, Workspace

    timestamps()
  end

  @doc false
  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [:label])
    |> validate_required([:label])
  end

  @doc false
  def create_changeset(definition, attrs, workspace_id) do
    workspace_definition = Workspaces.generate_definition!(workspace_id)
    next_version = Definitions.next_version(workspace_id)

    %{changes: %{label: label}} =
      changes =
      definition
      |> changeset(attrs)

    version_label = "v#{next_version} #{label}"

    full_definition =
      workspace_definition
      |> Map.merge(%{
        schema_version: @current_schema_version,
        workspace_id: workspace_id,
        version: next_version,
        version_label: version_label
      })

    yaml = Ymlr.document!(full_definition)

    changes
    |> put_change(:workspace_id, workspace_id)
    |> put_change(:data, workspace_definition)
    |> put_change(:schema_version, @current_schema_version)
    |> put_change(:version, next_version)
    |> put_change(:label, version_label)
    |> put_change(:yaml, yaml)
    |> validate_required([:workspace_id, :schema_version, :version, :data, :yaml])
    |> unique_constraint([:workspace_id, :version])
  end
end

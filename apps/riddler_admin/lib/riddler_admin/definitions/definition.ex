defmodule RiddlerAdmin.Definitions.Definition do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.PublishRequests.PublishRequest
  alias RiddlerAdmin.Workspaces.Workspace

  @current_schema_version 1

  @id_opts [prefix: "def", rand_size: 2]

  # @derive {Jason.Encoder, only: [:id, :schema_version, :version, :yaml, :workspace_id, :publish_request_id, :created_at]}
  @derive {Jason.Encoder, only: [:id, :schema_version, :version, :workspace_id, :publish_request_id]}
  schema "definitions" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :schema_version, :integer, null: false
    field :version, :integer, null: false
    field :label, :string, null: false

    field :data, :map, null: false
    field :yaml, :string, null: false

    # field :workspace_id, Ecto.UXID, null: false
    # field :publish_request_id, Ecto.UXID, null: false

    belongs_to :workspace, Workspace
    belongs_to :publish_request, PublishRequest

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(attrs) do
    changeset =
      %__MODULE__{}
      |> cast(attrs, [:data, :workspace_id, :publish_request_id, :label])

    definition_id = UXID.generate!(@id_opts)

    %{workspace_id: workspace_id, data: workspace_definition, label: label} = changeset |> apply_changes
    next_version = Definitions.next_version(workspace_id)
    version_label = "v#{next_version} #{label}"

    full_definition =
      workspace_definition
      |> Map.merge(%{
        schema_version: @current_schema_version,
        id: definition_id,
        workspace_id: workspace_id,
        version: next_version,
        version_label: version_label
      })
    yaml = Ymlr.document!(full_definition)

    changeset
    |> put_change(:id, definition_id)
    |> put_change(:schema_version, @current_schema_version)
    |> put_change(:version, next_version)
    |> put_change(:label, version_label)
    |> put_change(:yaml, yaml)
    |> validate_required([:workspace_id, :publish_request_id, :schema_version, :version, :data, :yaml])
    |> unique_constraint([:workspace_id, :version])
    |> unique_constraint([:publish_request_id])
  end
end

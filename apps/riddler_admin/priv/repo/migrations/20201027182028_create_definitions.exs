defmodule RiddlerAdmin.Repo.Migrations.CreateDefinitions do
  use Ecto.Migration

  def change do
    create table(:definitions) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :nothing), null: false
      add :publish_request_id, references(:publish_requests, on_delete: :nothing), null: false

      add :label, :text, null: false
      add :schema_version, :integer, null: false
      add :version, :integer, null: false
      add :data, :jsonb, null: false
      add :yaml, :text, null: false
    end

    create index(:definitions, [:workspace_id])
    create unique_index(:definitions, [:workspace_id, :version])
    create unique_index(:definitions, [:publish_request_id])
  end
end

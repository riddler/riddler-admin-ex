defmodule RiddlerAdmin.Repo.Migrations.CreateDefinitions do
  use Ecto.Migration

  def change do
    create table(:definitions) do
      add :version, :integer
      add :schema_version, :integer
      add :data, :map
      add :workspace_id, references(:workspaces, on_delete: :nothing)
      add :publish_request_id, references(:publish_requests, on_delete: :nothing)

      timestamps()
    end

    create index(:definitions, [:workspace_id])
    create index(:definitions, [:publish_request_id])
  end
end

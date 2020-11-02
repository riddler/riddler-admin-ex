defmodule RiddlerAdmin.Repo.Migrations.CreateConditions do
  use Ecto.Migration

  def change do
    create table(:conditions) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :name, :text, null: false
      add :key, :text, null: false
      add :source, :text, null: false
      add :instructions, :jsonb, null: false
    end

    create index(:conditions, [:workspace_id])
    create unique_index(:conditions, [:workspace_id, :key])
  end
end

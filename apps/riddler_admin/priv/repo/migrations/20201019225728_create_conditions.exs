defmodule RiddlerAdmin.Repo.Migrations.CreateConditions do
  use Ecto.Migration

  def change do
    create table(:conditions) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :key, :text
      add :source, :text
      add :instructions, :jsonb
    end

    create index(:conditions, [:workspace_id])
  end
end

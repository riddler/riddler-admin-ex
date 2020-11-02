defmodule RiddlerAdmin.Repo.Migrations.CreateEnvironments do
  use Ecto.Migration

  def change do
    create table(:environments) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :name, :text, null: false
      add :key, :text, null: false
    end

    create index(:environments, [:workspace_id])
    create unique_index(:environments, [:workspace_id, :key])
  end
end

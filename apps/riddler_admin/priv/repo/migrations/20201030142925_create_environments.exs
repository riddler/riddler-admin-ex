defmodule RiddlerAdmin.Repo.Migrations.CreateEnvironments do
  use Ecto.Migration

  def change do
    create table(:environments) do
      add :name, :text
      add :key, :text
      add :workspace_id, references(:workspaces, on_delete: :nothing)

      timestamps()
    end

    create index(:environments, [:workspace_id])
    create unique_index(:environments, [:workspace_id, :key])
  end
end

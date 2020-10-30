defmodule RiddlerAdmin.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :name, :text, null: false
      add :api_key, :text, null: false
      add :api_secret, :text, null: false
    end

    create index(:agents, [:workspace_id])
    create unique_index(:agents, [:api_key])
    create unique_index(:agents, [:api_secret])
  end
end

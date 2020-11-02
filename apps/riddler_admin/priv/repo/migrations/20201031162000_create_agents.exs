defmodule RiddlerAdmin.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :id, :text, primary_key: true
      timestamps()
      add :environment_id, references(:environments, on_delete: :delete_all), null: false

      add :name, :text, null: false
      add :key, :text, null: false
      add :api_key, :text, null: false
      add :api_secret, :text, null: false
    end

    create index(:agents, [:environment_id])
    create unique_index(:agents, [:environment_id, :key])
    create unique_index(:agents, [:api_key])
    create unique_index(:agents, [:api_secret])
  end
end

defmodule RiddlerAdmin.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :id, :text, primary_key: true
      timestamps()
      add :account_id, references(:accounts, on_delete: :delete_all), null: false

      add :name, :text
      add :api_key, :text
      add :api_secret, :text
    end

    create index(:agents, [:account_id])
  end
end

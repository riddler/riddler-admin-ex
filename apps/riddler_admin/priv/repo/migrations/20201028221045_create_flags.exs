defmodule RiddlerAdmin.Repo.Migrations.CreateFlags do
  use Ecto.Migration

  def change do
    create table(:flags) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :type, :text, null: false
      add :key, :text, null: false
    end

    create index(:flags, [:workspace_id])
  end
end

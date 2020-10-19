defmodule RiddlerAdmin.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :id, :text, primary_key: true
      timestamps()
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :owner_identity_id, references(:identities, on_delete: :nilify_all)

      add :name, :text
    end

    create index(:workspaces, [:account_id])
    create index(:workspaces, [:owner_identity_id])
  end
end

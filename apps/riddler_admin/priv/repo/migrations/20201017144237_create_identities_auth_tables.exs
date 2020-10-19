defmodule RiddlerAdmin.Repo.Migrations.CreateIdentitiesAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:identities) do
      add :id, :text, primary_key: true
      timestamps()
      add :confirmed_at, :utc_datetime_usec

      add :email, :citext, null: false
      add :hashed_password, :text, null: false
    end

    create unique_index(:identities, [:email])

    create table(:identities_tokens) do
      add :id, :text, primary_key: true
      timestamps(updated_at: false)
      add :identity_id, references(:identities, on_delete: :delete_all), null: false

      add :token, :binary, null: false
      add :context, :text, null: false
      add :sent_to, :text
    end

    create index(:identities_tokens, [:identity_id])
    create unique_index(:identities_tokens, [:context, :token])
  end
end

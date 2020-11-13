defmodule RiddlerAdmin.Repo.Migrations.Genesis do
  use Ecto.Migration

  def change do
    # === Auth / Infra

    create table(:accounts) do
      add :id, :text, primary_key: true
      timestamps()
      add :owner_identity_id, references(:identities, on_delete: :restrict), null: false

      add :name, :text, null: false
    end

    create index(:accounts, [:owner_identity_id])

    create table(:workspaces) do
      add :id, :text, primary_key: true
      timestamps()
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :owner_identity_id, references(:identities, on_delete: :nilify_all)

      add :name, :text, null: false
      add :key, :text, null: false
    end

    create index(:workspaces, [:account_id])
    create index(:workspaces, [:owner_identity_id])
    create unique_index(:workspaces, [:id, :key])

    create table(:definitions) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :nothing), null: false

      add :label, :text, null: false
      add :schema_version, :integer, null: false
      add :version, :integer, null: false
      add :data, :jsonb, null: false
      add :yaml, :text, null: false
    end

    create index(:definitions, [:workspace_id])
    create unique_index(:definitions, [:workspace_id, :version])

    create table(:environments) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :definition_id, references(:definitions, on_delete: :delete_all)

      add :name, :text, null: false
      add :key, :text, null: false
    end

    create index(:environments, [:workspace_id])
    create unique_index(:environments, [:workspace_id, :key])

    create table(:publish_requests) do
      add :id, :text, primary_key: true
      timestamps()
      add :approved_at, :utc_datetime_usec
      add :published_at, :utc_datetime_usec

      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :environment_id, references(:environments, on_delete: :delete_all), null: false
      add :definition_id, references(:definitions, on_delete: :nothing), null: false

      add :created_by_id, references(:identities, on_delete: :nothing)
      add :approved_by_id, references(:identities, on_delete: :nothing)
      add :published_by_id, references(:identities, on_delete: :nothing)

      add :status, :text, null: false
      add :subject, :text, null: false
      add :message, :text
    end

    create index(:publish_requests, [:workspace_id])
    create index(:publish_requests, [:environment_id])

    create index(:publish_requests, [:created_by_id])
    create index(:publish_requests, [:approved_by_id])
    create index(:publish_requests, [:published_by_id])

    # === Content

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

    create table(:flags) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :type, :text, null: false
      add :name, :text, null: false
      add :key, :text, null: false

      add :include_source, :text
      add :include_instructions, :jsonb
    end

    create index(:flags, [:workspace_id])
    create unique_index(:flags, [:workspace_id, :key])

    create table(:flag_segments) do
      add :id, :text, primary_key: true
      timestamps()
      add :flag_id, references(:flags, on_delete: :delete_all), null: false
      add :rank, :integer, null: false

      add :name, :text, null: false
      add :key, :text, null: false

      add :condition_source, :text
      add :condition_instructions, :jsonb
    end

    create index(:flag_segments, [:flag_id])
    create unique_index(:flag_segments, [:flag_id, :rank])
    create unique_index(:flag_segments, [:flag_id, :key])

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

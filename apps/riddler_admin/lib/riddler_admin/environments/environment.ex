defmodule RiddlerAdmin.Environments.Environment do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "env", rand_size: 3]

  @derive {Jason.Encoder, only: [:id, :name, :key]}
  schema "environments" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :name, :string
    field :key, :string

    belongs_to :workspace, Workspace

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(agent, attrs, workspace_id) do
    agent
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
  end

  @doc false
  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [:name, :key])
    |> put_key_change()
    |> validate_required([:name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
  end

  defp put_key_change(%{data: %{key: nil}, changes: %{name: name}} = changeset)
       when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_]/, "_")
      |> String.replace(~r/_+/, "_")

    changeset
    |> put_change(:key, key)
  end

  defp put_key_change(changeset) do
    changeset
  end
end

defmodule RiddlerAdmin.ContentBlocks.ContentBlock do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Elements.Element

  @id_opts [prefix: "cbl", size: :small]

  @derive {Jason.Encoder, only: [:id, :name, :key, :elements]}
  schema "content_blocks" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :name, :string
    field :key, :string

    belongs_to :workspace, RiddlerAdmin.Workspaces.Workspace

    has_many :elements, Element, references: :id

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def create_changeset(content_block, attrs, workspace_id) do
    content_block
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
    |> validate_required([:workspace_id])
  end

  @doc false
  def changeset(content_block, attrs) do
    content_block
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

  defp put_key_change(changeset), do: changeset
end

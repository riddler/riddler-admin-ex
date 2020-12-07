defmodule RiddlerAdmin.Elements.Element do
  use RiddlerAdmin.Schema

  @id_opts [prefix: "el", size: :medium]

  @derive {Jason.Encoder, only: [:id, :type, :name, :key, :include_source, :include_instructions, :text]}
  schema "elements" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :type, :string, null: false
    field :rank, :integer, null: false
    field :name, :string, null: false
    field :key, :string, null: false

    field :include_source, :string
    field :include_instructions, Ecto.PredicatorInstructions

    field :text, :string

    belongs_to :content_block, RiddlerAdmin.ContentBlocks.ContentBlock

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def create_changeset(element, attrs, content_block_id) do
    element
    |> changeset(attrs)
    |> put_change(:content_block_id, content_block_id)
    |> validate_required([:content_block_id])
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:type, :rank, :name, :key, :text])
    |> put_key_change()
    |> validate_required([:type, :rank, :name, :key, :text])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
    |> compile()
  end

  defp compile(changeset) do
    case get_change(changeset, :include_source) do
      nil -> changeset
      source -> compile_instructions(changeset, source)
    end
  end

  defp compile_instructions(changeset, nil), do: changeset

  defp compile_instructions(changeset, source) when is_binary(source),
    do:
      changeset
      |> put_change(:include_instructions, Predicator.compile!(source))

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

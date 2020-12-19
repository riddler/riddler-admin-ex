defmodule RiddlerAdmin.Elements.Element do
  use RiddlerAdmin.Schema

  @id_opts [prefix: "el", size: :medium]

  # See Jason.Encoder below
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
    belongs_to :element, __MODULE__
    has_many :elements, __MODULE__, references: :id

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
  def create_child_changeset(element, attrs, parent_element_id) do
    element
    |> child_changeset(attrs)
    |> put_change(:element_id, parent_element_id)
    |> validate_required([:element_id])
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:type, :rank, :name, :key, :text, :include_source])
    |> put_key_change()
    |> validate_required([:type, :rank, :name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
    |> compile()
  end

  @doc false
  def child_changeset(element, attrs) do
    element
    |> cast(attrs, [:type, :rank, :text, :include_source])
    |> put_key_change()
    |> validate_required([:type, :rank, :text])
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

defimpl Jason.Encoder, for: RiddlerAdmin.Elements.Element do
  alias RiddlerAdmin.Elements

  def encode(%{type: "Variant"} = element, opts) do
    children =
      element.id
      |> Elements.list_children_elements()

    element = %{element | elements: children}

    Jason.Encode.map(
      Map.take(
        element,
        [
          :id,
          :type,
          :name,
          :key,
          :include_source,
          :include_instructions,
          :elements
        ]
      ),
      opts
    )
  end

  def encode(element, opts) do
    Jason.Encode.map(
      Map.take(
        element,
        [
          :id,
          :type,
          :name,
          :key,
          :include_source,
          :include_instructions,
          :text
        ]
      ),
      opts
    )
  end
end

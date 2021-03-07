defmodule RiddlerAdmin.Agents.Agent do
  use RiddlerAdmin.Schema, id_prefix: "ag"

  schema "agents" do
    field :name, :string
    field :key, :string
    field :api_key, :string
    field :api_secret, :string

    belongs_to :environment, RiddlerAdmin.Environments.Environment

    timestamps()
  end

  @doc false
  def create_changeset(agent, attrs, environment_id) do
    agent
    |> changeset(attrs)
    |> put_change(:environment_id, environment_id)
    |> put_change(:api_key, generate_api_key())
    |> put_change(:api_secret, generate_api_secret())
    |> validate_required([:environment_id, :api_key, :api_secret])
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :key])
    |> put_key_change()
    |> validate_required([:name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
  end

  defp generate_api_key(), do: UXID.generate!(prefix: "apikey", size: :medium)

  defp generate_api_secret(length \\ 64) do
    random_string =
      length
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64()
      |> binary_part(0, length)
      |> String.replace(~r/-/, "_")

    "apisecret_#{random_string}"
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

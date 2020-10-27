defmodule RiddlerAdmin.Agents.Agent do
  use RiddlerAdmin.Schema

  @id_opts [prefix: "ag", rand_size: 2]

  schema "agents" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    field :account_id, Ecto.UXID

    field :name, :string
    field :api_key, :string
    field :api_secret, :string

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def create_changeset(agent, attrs, account_id) do
    agent
    |> changeset(attrs)
    |> put_change(:account_id, account_id)
    |> put_change(:api_key, generate_api_key())
    |> put_change(:api_secret, generate_api_secret())
    |> validate_required([:account_id, :api_key, :api_secret])
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  defp generate_api_key(), do: UXID.generate!(prefix: "apikey", rand_size: 5)

  defp generate_api_secret(length \\ 40),
    do:
      length
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64()
      |> binary_part(0, length)
end

defmodule RiddlerAdmin.Repo do
  use Ecto.Repo,
    otp_app: :riddler_admin,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config =
      config
      |> Keyword.put_new(:migration_primary_key, false)
      |> Keyword.put_new(:migration_foreign_key, column: :id, type: :text)

    {:ok, config}
  end
end

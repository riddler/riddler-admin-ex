defmodule RiddlerAdmin.Repo do
  use Ecto.Repo,
    otp_app: :riddler_admin,
    adapter: Ecto.Adapters.Postgres
end

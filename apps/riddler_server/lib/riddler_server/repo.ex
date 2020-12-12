defmodule RiddlerServer.Repo do
  use Ecto.Repo,
    otp_app: :riddler_server,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config =
      config
      |> Keyword.put_new(:database, Confex.get_env(:riddler_server, :database_name))
      |> Keyword.put_new(:username, Confex.get_env(:riddler_server, :database_username))
      |> Keyword.put_new(:password, Confex.get_env(:riddler_server, :database_password))
      |> Keyword.put_new(:hostname, Confex.get_env(:riddler_server, :database_host))
      |> Keyword.put_new(:port, Confex.get_env(:riddler_server, :database_port))
      |> Keyword.put_new(:log, Confex.get_env(:riddler_server, :ecto_log_level))

    {:ok, config}
  end
end

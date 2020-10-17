defmodule RiddlerAdmin.MixProject do
  use Mix.Project

  @name "RiddlerAdmin"
  @app :riddler_admin
  @description "Admin application for managing Riddler"
  @version "0.1.0"

  @deps [
    # Required
    {:ecto_sql, "~> 3.4"},
    {:jason, "~> 1.0"},
    {:phoenix_pubsub, "~> 2.0"},
    {:postgrex, ">= 0.0.0"},
    # {:uxid, "~> 0.0"}
    {:uxid, path: "../../../../../uxid/impl/ex"},

    # Development
    {:phx_gen_auth, "~> 0.5", only: [:dev], runtime: false}
  ]

  def application do
    [
      mod: {RiddlerAdmin.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def project() do
    [
      app: @app,
      name: @name,
      description: @description,
      version: @version,
      deps: @deps,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # ---------------------------------------------------------------------------
  # Private

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end

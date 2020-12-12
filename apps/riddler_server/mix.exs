defmodule RiddlerServer.MixProject do
  use Mix.Project

  @name "RiddlerServer"
  @app :riddler_server
  @description "Server application for running Riddler"
  @version "0.1.0"

  @aliases [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]

  @deps [
    # Umbrella
    {:messaging, in_umbrella: true},

    # Required
    {:confex, "~> 3.4"},
    {:ecto_sql, "~> 3.4"},
    {:gettext, "~> 0.11"},
    {:jason, "~> 1.0"},
    {:liquid, "~> 0.9"},
    {:murmur, "~> 1.0"},
    {:phoenix, "~> 1.5.6"},
    {:phoenix_ecto, "~> 4.1"},
    {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
    {:plug_cowboy, "~> 2.0"},
    {:postgrex, ">= 0.0.0"},
    {:predicator, "~> 0.9"},
    {:telemetry_metrics, "~> 0.4"},
    {:telemetry_poller, "~> 0.4"},
    {:tesla, "~> 1.3"},
    {:yaml_elixir, "~> 2.5"}
  ]

  def application do
    [
      mod: {RiddlerServer.Application, []},
      extra_applications: [:liquid, :logger, :runtime_tools]
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
      aliases: @aliases,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # ---------------------------------------------------------------------------
  # Private

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end

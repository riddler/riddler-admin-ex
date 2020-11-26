defmodule RiddlerAgent.MixProject do
  use Mix.Project

  @name "RiddlerAgent"
  @app :riddler_agent
  @description "Agent application for running Riddler"
  @version "0.1.0"

  @deps [
    # Umbrella
    {:messaging, in_umbrella: true},

    # Required
    {:confex, "~> 3.4"},
    {:jason, "~> 1.0"},
    {:predicator, "~> 0.9"},
    {:tesla, "~> 1.3"},
    {:yaml_elixir, "~> 2.5"}
  ]

  def application do
    [
      mod: {RiddlerAgent.Application, []},
      extra_applications: [:logger]
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
      setup: ["deps.get", "deps.compile"]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end

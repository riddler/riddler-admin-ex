defmodule Messaging.MixProject do
  use Mix.Project

  @name "Messaging"
  @app :messaging
  @description "Messaging for Riddler apps"
  @version "0.1.0"

  @deps [
    # Required
    {:confex, "~> 3.4"},
    {:elixir_nsq, "~> 1.1"},
    {:jason, "~> 1.0"}
  ]

  def application do
    [
      mod: {Messaging.Application, []},
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
      setup: ["deps.get"]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end

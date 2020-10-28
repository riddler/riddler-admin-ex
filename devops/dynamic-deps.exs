defmodule Build.MixProject do
  @doc """
  This represents a project which depends on all packages listed in the
  mix.lock file.

  This is useful in Docker builds as a way to cache all dependencies of an
  Elixir umbrella app.
  """

  use Mix.Project

  def project() do
    [
      version: "1.0.0",
      app: :riddler_admin,
      deps: deps(),
      lockfile: "mix.lock"
    ]
  end

  defp deps() do
    lockfile = "mix.lock"
    opts = [file: lockfile, warn_on_unnecessary_quotes: false]

    lockfile
    |> File.read!()
    |> Code.string_to_quoted!(opts)
    |> Code.eval_quoted([], opts)
    |> elem(0)
    |> Enum.flat_map(&map_dependency/1)
  end

  # Overriding the hex package to use to get the dep
  defp map_dependency({key, value}) when elem(value, 0) == :hex and key != elem(value, 1) do
    aliased_package = elem(value, 1)

    warn("""
    WARN: Hex package aliased: #{key} -> #{aliased_package}. This means someone is overriding the hex package "#{
      key
    }" with the package "#{aliased_package}". Audit your package dependencies if this is unexpected.
    """)

    [{key, ">= 0.0.0", override: true, hex: aliased_package}]
  end

  defp map_dependency({key, value}) when elem(value, 0) == :hex do
    [{key, ">= 0.0.0", override: true}]
  end

  defp map_dependency({key, {:git, repo, _ref, other}}) do
    case other do
      [tag: tag] ->
        [{key, ">= 0.0.0", git: repo, tag: tag}]

      [branch: branch] ->
        [{key, ">= 0.0.0", git: repo, branch: branch}]

      [ref: ref] ->
        [{key, ">= 0.0.0", git: repo, ref: ref}]

      [] ->
        [{key, ">= 0.0.0", git: repo}]
    end
  end

  defp map_dependency({key, value}) do
    raise "Unknown lock format #{inspect({key, value})}"
  end

  defp warn(message) do
    [:yellow, message]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end

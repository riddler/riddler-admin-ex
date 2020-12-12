defmodule RiddlerServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias RiddlerServer.Infra.Consumers.DefinitionConsumer

  @dev_base_url "http://lh:16180"

  @seed_api_key "apikey_TESTSEED"
  @seed_api_secret "apisecret_TESTSEED"

  @impl true
  def start(_type, _args) do
    children = [
      # Start up the configuration
      {RiddlerServer.Config,
       %{api_key: api_key(), api_secret: api_secret(), base_url: base_url()}},
      # Start up the storage for Definitions
      RiddlerServer.MemoryStore,
      DefinitionConsumer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiddlerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # defp workspace_id(), do: @seed_workspace_id

  defp api_key(), do: Confex.get_env(:riddler_server, :api_key, @seed_api_key)
  defp api_secret(), do: Confex.get_env(:riddler_server, :api_secret, @seed_api_secret)

  defp base_url(), do: Confex.get_env(:riddler_server, :base_url, @dev_base_url)
end

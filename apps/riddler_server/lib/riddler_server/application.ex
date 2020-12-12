defmodule RiddlerServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias RiddlerServer.Infra.Consumers.DefinitionConsumer

  @dev_base_url "http://lh:2111"

  @seed_api_key "apikey_TESTSEED"
  @seed_api_secret "apisecret_TESTSEED"

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RiddlerServer.Repo,
      # Start the Telemetry supervisor
      RiddlerServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RiddlerServer.PubSub},
      # Start the Endpoint (http/https)
      RiddlerServerWeb.Endpoint,

      # Start the Guide configuration
      {RiddlerServer.Config,
       %{api_key: api_key(), api_secret: api_secret(), base_url: base_url()}},
      # Start the storage for Workspace Definitions
      RiddlerServer.MemoryStore,
      # Start the messaging consumer for Workspace Definitions
      DefinitionConsumer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiddlerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RiddlerServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp api_key(), do: Confex.get_env(:riddler_server, :api_key, @seed_api_key)
  defp api_secret(), do: Confex.get_env(:riddler_server, :api_secret, @seed_api_secret)
  defp base_url(), do: Confex.get_env(:riddler_server, :base_url, @dev_base_url)
end

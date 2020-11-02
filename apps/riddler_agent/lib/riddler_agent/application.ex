defmodule RiddlerAgent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias RiddlerAdmin.Messaging
  alias RiddlerAgent.Messaging.Consumers.DefinitionConsumer

  @dev_base_url "http://lh:6181"

  @seed_api_key "apikey_01EP4FXYHR2NE4W8S7"
  @seed_api_secret "apisecret_lPQX1OUtOTKMdzECAgLYILmLk5rWsSBfADnbk5ua7Cms_ogRT_qXWcfHP2Y32f6k"

  @impl true
  def start(_type, _args) do
    children = [
      # Start up the configuration
      {RiddlerAgent.Config, %{api_key: api_key(), api_secret: api_secret(), base_url: base_url()}},
      # Start up the storage for Definitions
      RiddlerAgent.MemoryStore
    ]

    # This is bad
    # (not storing process here - Messaging and NSQPubSub need the attention)
    # help please!
    Messaging.subscribe("definitions", "riddler_agent", DefinitionConsumer)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiddlerAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end


  # defp workspace_id(), do: @seed_workspace_id

  defp api_key(), do: Confex.get_env(:riddler_agent, :api_key, @seed_api_key)
  defp api_secret(), do: Confex.get_env(:riddler_agent, :api_secret, @seed_api_secret)

  defp base_url(), do: Confex.get_env(:riddler_agent, :base_url, @dev_base_url)
end

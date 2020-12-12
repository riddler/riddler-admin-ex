defmodule RiddlerServer.Infra.Consumers.DefinitionConsumer do
  use Messaging.Consumer, topic: "definitions", group: "agent-persist"

  require Logger

  def handle_message(body, %{attempts: _attempts, id: _message_id, timestamp: _timestamp}) do
    Logger.info("[RSRV] Received Definition")

    with %{"environment_id" => environment_id, "yaml" => yaml} <- Jason.decode!(body) do
      RiddlerServer.store_definition(yaml, environment_id)
    end
  end
end

defmodule RiddlerAdmin.PublishRequests.UseCases.PublishDefinition do
  alias RiddlerAdmin.Event
  alias RiddlerAdmin.Messaging

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.PublishRequests.PublishRequest

  # @derive {Jason.Encoder, only: [:id, :schema_version, :version, :workspace_id, :publish_request_id, :label]}
  @derive {Jason.Encoder, only: [:id, :schema_version, :version, :workspace_id, :publish_request_id, :yaml]}
  defstruct [:id, :schema_version, :version, :workspace_id, :publish_request_id, :yaml, :label, :data]

  def new(%PublishRequest{
    id: publish_request_id,
    workspace_id: workspace_id,
    subject: label,
    data: data
  }) do
    %__MODULE__{
      workspace_id: workspace_id,
      publish_request_id: publish_request_id,
      data: data,
      label: label
    }
  end

  def execute(%__MODULE__{
    workspace_id: workspace_id,
    publish_request_id: publish_request_id,
    data: data,
    label: label
  } = use_case) do
    {:ok, definition} = Definitions.create_definition(%{
      workspace_id: workspace_id,
      publish_request_id: publish_request_id,
      data: data,
      label: label
    })

    %{use_case | 
      id: definition.id,
      schema_version: definition.schema_version,
      version: definition.version,
      label: definition.label,
      yaml: definition.yaml
    }
    |> Map.drop([:label])
    |> Event.new("definitions")
    |> Messaging.record()
  end
end

defmodule RiddlerAdmin.PublishRequests.UseCases.PublishDefinition do
  alias RiddlerAdmin.Event
  alias RiddlerAdmin.Messaging

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.Definitions.Definition
  alias RiddlerAdmin.PublishRequests.PublishRequest

  @derive {Jason.Encoder,
           only: [:id, :schema_version, :version, :workspace_id, :publish_request_id, :yaml]}
  defstruct [
    :id,
    :schema_version,
    :version,
    :workspace_id,
    :environment_id,
    :publish_request_id,
    :yaml,
    :label
  ]

  def new(%PublishRequest{
        id: publish_request_id,
        workspace_id: workspace_id,
        definition_id: definition_id,
        environment_id: environment_id,
        subject: label
      }) do
    %__MODULE__{
      id: definition_id,
      workspace_id: workspace_id,
      environment_id: environment_id,
      publish_request_id: publish_request_id,
      label: label
    }
  end

  def new(%Definition{
        workspace_id: workspace_id,
        label: label,
        yaml: yaml,
        schema_version: schema_version,
        version: version,
        id: id
      }) do
    %__MODULE__{
      id: id,
      schema_version: schema_version,
      version: version,
      workspace_id: workspace_id,
      label: label,
      yaml: yaml
    }
  end

  def execute(
        %__MODULE__{
          id: id
        } = use_case
      )
      when not is_nil(id) do
    definition = Definitions.get_definition!(id)

    %{use_case | yaml: definition.yaml}
    |> Map.drop([:label])
    |> Event.new("definitions")
    |> Messaging.record()
  end
end

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
    :publish_request_id,
    :yaml,
    :label,
    :data
  ]

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

  def new(%Definition{
        workspace_id: workspace_id,
        label: label,
        data: data,
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
      # publish_request_id: publish_request_id,
      data: data,
      label: label,
      yaml: yaml
    }
  end

  # The Definition hasn't been created yet - create then publish
  def execute(%__MODULE__{
        id: nil,
        schema_version: nil,
        version: nil,
        workspace_id: workspace_id,
        publish_request_id: publish_request_id,
        data: data,
        label: label
      }) do
    {:ok, definition} =
      Definitions.create_definition(%{
        workspace_id: workspace_id,
        publish_request_id: publish_request_id,
        data: data,
        label: label
      })

    definition
    |> new()
    |> execute()
  end

  # We have everything - publish the definition
  def execute(
        %__MODULE__{
          id: id
        } = use_case
      )
      when not is_nil(id) do
    use_case
    |> Map.drop([:label])
    |> Event.new("definitions")
    |> Messaging.record()
  end
end

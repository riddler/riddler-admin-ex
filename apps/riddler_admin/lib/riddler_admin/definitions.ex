defmodule RiddlerAdmin.Definitions do
  @moduledoc """
  The Definitions context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo

  alias RiddlerAdmin.Definitions.Definition

  def next_version(workspace_id) do
    previous_version =
      Definition
    |> where([def], def.workspace_id == ^workspace_id)
    |> select([def], max(def.version))
    |> Repo.one!()

    (previous_version || 0) + 1
  end

  def list_workspace_definitions(workspace_id) do
    Definition
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of definitions.

  ## Examples

      iex> list_definitions()
      [%Definition{}, ...]

  """
  def list_definitions do
    Repo.all(Definition)
  end

  @doc """
  Gets a single definition.

  Raises `Ecto.NoResultsError` if the Definition does not exist.

  ## Examples

      iex> get_definition!(123)
      %Definition{}

      iex> get_definition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_definition!(id), do: Repo.get!(Definition, id)

  @doc """
  Creates a definition.
  """
  def create_definition(attrs) do
    # %{data: workspace_definition} = PublishRequests.get_publish_request!(publish_request_id)

    Definition.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a definition.

  ## Examples

      iex> delete_definition(definition)
      {:ok, %Definition{}}

      iex> delete_definition(definition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_definition(%Definition{} = definition) do
    Repo.delete(definition)
  end
end

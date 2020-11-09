defmodule RiddlerAdmin.PublishRequests do
  @moduledoc """
  The PublishRequests context.
  """

  import Ecto.Query, warn: false

  alias RiddlerAdmin.Identities.Identity
  alias RiddlerAdmin.Repo
  alias RiddlerAdmin.PublishRequests.PublishRequest
  alias RiddlerAdmin.PublishRequests.UseCases.PublishDefinition

  require Logger

  def approve(%PublishRequest{} = publish_request, %Identity{id: approver_id}) do
    publish_request
    |> PublishRequest.approve_changeset(approver_id)
    |> Repo.update()
  end

  def publish(%PublishRequest{} = publish_request, %Identity{id: publisher_id}) do
    {:ok, pr} =
      create_result =
      publish_request
      |> PublishRequest.publish_changeset(publisher_id)
      |> Repo.update()

    pr
    |> PublishDefinition.new()
    |> PublishDefinition.execute()

    create_result
  end

  def list_workspace_publish_requests(workspace_id) do
    PublishRequest
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of publish_requests.

  ## Examples

      iex> list_publish_requests()
      [%PublishRequest{}, ...]

  """
  def list_publish_requests do
    Repo.all(PublishRequest)
  end

  @doc """
  Gets a single publish_request.

  Raises `Ecto.NoResultsError` if the Publish request does not exist.

  ## Examples

      iex> get_publish_request!(123)
      %PublishRequest{}

      iex> get_publish_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_publish_request!(id) do
    PublishRequest
    |> preload(:definition)
    |> Repo.get!(id)
  end

  @doc """
  Creates a publish_request.

  ## Examples

      iex> create_publish_request(%{field: value})
      {:ok, %PublishRequest{}}

      iex> create_publish_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_publish_request(attrs, workspace_id, author_id) do
    %PublishRequest{}
    |> PublishRequest.create_changeset(attrs, workspace_id, author_id)
    |> Repo.insert()
  end

  @doc """
  Updates a publish_request.

  ## Examples

      iex> update_publish_request(publish_request, %{field: new_value})
      {:ok, %PublishRequest{}}

      iex> update_publish_request(publish_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_publish_request(%PublishRequest{} = publish_request, attrs) do
    publish_request
    |> PublishRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a publish_request.

  ## Examples

      iex> delete_publish_request(publish_request)
      {:ok, %PublishRequest{}}

      iex> delete_publish_request(publish_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_publish_request(%PublishRequest{} = publish_request) do
    Repo.delete(publish_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking publish_request changes.

  ## Examples

      iex> change_publish_request(publish_request)
      %Ecto.Changeset{data: %PublishRequest{}}

  """
  def change_publish_request(%PublishRequest{} = publish_request, attrs \\ %{}) do
    PublishRequest.changeset(publish_request, attrs)
  end
end

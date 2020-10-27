defmodule RiddlerAdmin.PublishRequests do
  @moduledoc """
  The PublishRequests context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo

  alias RiddlerAdmin.PublishRequests.PublishRequest

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
  def get_publish_request!(id), do: Repo.get!(PublishRequest, id)

  @doc """
  Creates a publish_request.

  ## Examples

      iex> create_publish_request(%{field: value})
      {:ok, %PublishRequest{}}

      iex> create_publish_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_publish_request(attrs \\ %{}) do
    %PublishRequest{}
    |> PublishRequest.changeset(attrs)
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

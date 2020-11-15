defmodule RiddlerAdmin.Previews do
  @moduledoc """
  The Previews context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo

  alias RiddlerAdmin.Previews.Preview
  alias RiddlerAdmin.Previews.PreviewContext

  def list_workspace_preview_contexts(workspace_id) do
    PreviewContext
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of previews.

  ## Examples

      iex> list_previews()
      [%Preview{}, ...]

  """
  def list_previews do
    Repo.all(Preview)
  end

  @doc """
  Gets a single preview.

  Raises `Ecto.NoResultsError` if the Preview does not exist.

  ## Examples

      iex> get_preview!(123)
      %Preview{}

      iex> get_preview!(456)
      ** (Ecto.NoResultsError)

  """
  def get_preview!(id), do: Repo.get!(Preview, id)

  @doc """
  Creates a preview.

  ## Examples

      iex> create_preview(%{field: value})
      {:ok, %Preview{}}

      iex> create_preview(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_preview(attrs \\ %{}) do
    %Preview{}
    |> Preview.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a preview.

  ## Examples

      iex> update_preview(preview, %{field: new_value})
      {:ok, %Preview{}}

      iex> update_preview(preview, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_preview(%Preview{} = preview, attrs) do
    preview
    |> Preview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a preview.

  ## Examples

      iex> delete_preview(preview)
      {:ok, %Preview{}}

      iex> delete_preview(preview)
      {:error, %Ecto.Changeset{}}

  """
  def delete_preview(%Preview{} = preview) do
    Repo.delete(preview)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking preview changes.

  ## Examples

      iex> change_preview(preview)
      %Ecto.Changeset{data: %Preview{}}

  """
  def change_preview(%Preview{} = preview, attrs \\ %{}) do
    Preview.changeset(preview, attrs)
  end

  @doc """
  Returns the list of preview_contexts.

  ## Examples

      iex> list_preview_contexts()
      [%PreviewContext{}, ...]

  """
  def list_preview_contexts do
    Repo.all(PreviewContext)
  end

  @doc """
  Gets a single preview_context.

  Raises `Ecto.NoResultsError` if the Preview context does not exist.

  ## Examples

      iex> get_preview_context!(123)
      %PreviewContext{}

      iex> get_preview_context!(456)
      ** (Ecto.NoResultsError)

  """
  def get_preview_context!(id), do: Repo.get!(PreviewContext, id)

  @doc """
  Creates a preview_context.

  ## Examples

      iex> create_preview_context(%{field: value})
      {:ok, %PreviewContext{}}

      iex> create_preview_context(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_preview_context(attrs \\ %{}, workspace_id) do
    %PreviewContext{}
    |> PreviewContext.create_changeset(attrs, workspace_id)
    |> Repo.insert()
  end

  @doc """
  Updates a preview_context.

  ## Examples

      iex> update_preview_context(preview_context, %{field: new_value})
      {:ok, %PreviewContext{}}

      iex> update_preview_context(preview_context, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_preview_context(%PreviewContext{} = preview_context, attrs) do
    preview_context
    |> PreviewContext.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a preview_context.

  ## Examples

      iex> delete_preview_context(preview_context)
      {:ok, %PreviewContext{}}

      iex> delete_preview_context(preview_context)
      {:error, %Ecto.Changeset{}}

  """
  def delete_preview_context(%PreviewContext{} = preview_context) do
    Repo.delete(preview_context)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking preview_context changes.

  ## Examples

      iex> change_preview_context(preview_context)
      %Ecto.Changeset{data: %PreviewContext{}}

  """
  def change_preview_context(%PreviewContext{} = preview_context, attrs \\ %{}) do
    PreviewContext.changeset(preview_context, attrs)
  end
end

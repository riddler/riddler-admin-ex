defmodule RiddlerAdmin.ContentBlocks do
  @moduledoc """
  The ContentBlocks context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo

  alias RiddlerAdmin.ContentBlocks.ContentBlock

  def list_workspace_content_blocks(workspace_id) do
    ContentBlock
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of content_blocks.

  ## Examples

      iex> list_content_blocks()
      [%ContentBlock{}, ...]

  """
  def list_content_blocks do
    Repo.all(ContentBlock)
  end

  @doc """
  Gets a single content_block.

  Raises `Ecto.NoResultsError` if the ContentBlock does not exist.

  ## Examples

      iex> get_content_block!(123)
      %ContentBlock{}

      iex> get_content_block!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content_block!(id), do: Repo.get!(ContentBlock, id)

  @doc """
  Creates a content_block.
  """
  def create_content_block(attrs, workspace_id) do
    %ContentBlock{}
    |> ContentBlock.create_changeset(attrs, workspace_id)
    |> Repo.insert()
  end

  @doc """
  Updates a content_block.

  ## Examples

      iex> update_content_block(content_block, %{field: new_value})
      {:ok, %ContentBlock{}}

      iex> update_content_block(content_block, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content_block(%ContentBlock{} = content_block, attrs) do
    content_block
    |> ContentBlock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a content_block.

  ## Examples

      iex> delete_content_block(content_block)
      {:ok, %ContentBlock{}}

      iex> delete_content_block(content_block)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content_block(%ContentBlock{} = content_block) do
    Repo.delete(content_block)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content_block changes.

  ## Examples

      iex> change_content_block(content_block)
      %Ecto.Changeset{data: %ContentBlock{}}

  """
  def change_content_block(%ContentBlock{} = content_block, attrs \\ %{}) do
    ContentBlock.changeset(content_block, attrs)
  end
end

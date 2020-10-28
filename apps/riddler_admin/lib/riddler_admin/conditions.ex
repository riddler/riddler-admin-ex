defmodule RiddlerAdmin.Conditions do
  @moduledoc """
  The Conditions context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo
  alias RiddlerAdmin.Conditions.Condition

  def generate_id(_model \\ :condition) do
    Condition.id_opts()
    |> UXID.generate!()
  end

  @doc """
  Creates a condition with the provided workspace.
  """
  def create_condition_with_workspace(attrs \\ %{}, workspace_id) do
    %Condition{}
    |> Condition.create_changeset(attrs, workspace_id)
    |> Repo.insert()
  end

  @doc """
  Returns the list of conditions.

  ## Examples

      iex> list_conditions()
      [%Condition{}, ...]

  """
  def list_conditions do
    Repo.all(Condition)
  end

  @doc """
  Returns only the list of workspaces in the current workspace.
  """
  def list_workspace_conditions(workspace_id) when is_binary(workspace_id) do
    Condition
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  @doc """
  Gets a single condition.

  Raises `Ecto.NoResultsError` if the Condition does not exist.

  ## Examples

      iex> get_condition!(123)
      %Condition{}

      iex> get_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_condition!(id), do: Repo.get!(Condition, id)

  @doc """
  Creates a condition.

  ## Examples

      iex> create_condition(%{field: value})
      {:ok, %Condition{}}

      iex> create_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_condition(attrs \\ %{}) do
    %Condition{}
    |> Condition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a condition with the provided account.
  """
  def create_condition_with_account(attrs \\ %{}, account_id) do
    %Condition{}
    |> Condition.create_changeset(attrs, account_id)
    |> Repo.insert()
  end

  @doc """
  Updates a condition.

  ## Examples

      iex> update_condition(condition, %{field: new_value})
      {:ok, %Condition{}}

      iex> update_condition(condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_condition(%Condition{} = condition, attrs) do
    condition
    |> Condition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a condition.

  ## Examples

      iex> delete_condition(condition)
      {:ok, %Condition{}}

      iex> delete_condition(condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_condition(%Condition{} = condition) do
    Repo.delete(condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking condition changes.

  ## Examples

      iex> change_condition(condition)
      %Ecto.Changeset{data: %Condition{}}

  """
  def change_condition(%Condition{} = condition, attrs \\ %{}) do
    Condition.changeset(condition, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for creating a new Condition.

  ## Examples

      iex> new_condition(attrs)
      %Ecto.Changeset{data: %Condition{}}

  """
  def new_condition(attrs \\ %{}) do
    %Condition{}
    |> Condition.changeset(attrs)
  end
end

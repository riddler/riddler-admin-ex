defmodule RiddlerAdmin.Flags do
  @moduledoc """
  The Flags context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo

  alias RiddlerAdmin.Flags.Flag
  alias RiddlerAdmin.Flags.FlagTreatment

  def list_workspace_flags(workspace_id) do
    Flag
    |> where(workspace_id: ^workspace_id)
    |> Repo.all()
  end

  def list_flag_treatments(flag_id) do
    FlagTreatment
    |> where(flag_id: ^flag_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of flags.

  ## Examples

      iex> list_flags()
      [%Flag{}, ...]

  """
  def list_flags do
    Repo.all(Flag)
  end

  @doc """
  Gets a single flag.

  Raises `Ecto.NoResultsError` if the Flag does not exist.

  ## Examples

      iex> get_flag!(123)
      %Flag{}

      iex> get_flag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flag!(id), do: Repo.get!(Flag, id)

  @doc """
  Creates a flag.

  ## Examples

      iex> create_flag(%{field: value})
      {:ok, %Flag{}}

      iex> create_flag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flag(attrs, workspace_id) do
    %Flag{}
    |> Flag.create_changeset(attrs, workspace_id)
    |> Repo.insert()
  end

  @doc """
  Updates a flag.

  ## Examples

      iex> update_flag(flag, %{field: new_value})
      {:ok, %Flag{}}

      iex> update_flag(flag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flag(%Flag{} = flag, attrs) do
    flag
    |> Flag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a flag.

  ## Examples

      iex> delete_flag(flag)
      {:ok, %Flag{}}

      iex> delete_flag(flag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flag(%Flag{} = flag) do
    Repo.delete(flag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flag changes.

  ## Examples

      iex> change_flag(flag)
      %Ecto.Changeset{data: %Flag{}}

  """
  def change_flag(%Flag{} = flag, attrs \\ %{}) do
    Flag.changeset(flag, attrs)
  end

  ### Flag Treatments ###

  @doc """
  Creates a flag tretment.
  """
  def create_flag_treatment(attrs, flag_id) do
    %FlagTreatment{}
    |> FlagTreatment.create_changeset(attrs, flag_id)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flag treatment changes.
  """
  def change_flag_treatment(%FlagTreatment{} = flag_treatment, attrs \\ %{}) do
    FlagTreatment.changeset(flag_treatment, attrs)
  end

  @doc """
  Gets a single flag treatment.

  Raises `Ecto.NoResultsError` if the FlagTreatment does not exist.
  """
  def get_flag_treatment!(id), do: Repo.get!(FlagTreatment, id)

  @doc """
  Updates a flag treatment.
  """
  def update_flag_treatment(%FlagTreatment{} = flag_treatment, attrs) do
    flag_treatment
    |> FlagTreatment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a flag treatment.
  """
  def delete_flag_treatment(%FlagTreatment{} = flag_treatment) do
    Repo.delete(flag_treatment)
  end
end

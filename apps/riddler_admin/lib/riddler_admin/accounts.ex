defmodule RiddlerAdmin.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RiddlerAdmin.Repo
  alias RiddlerAdmin.Accounts.{Identity, IdentityToken, IdentityNotifier}

  ## Database getters

  @doc """
  Gets a identity by email.

  ## Examples

      iex> get_identity_by_email("foo@example.com")
      %Identity{}

      iex> get_identity_by_email("unknown@example.com")
      nil

  """
  def get_identity_by_email(email) when is_binary(email) do
    Repo.get_by(Identity, email: email)
  end

  @doc """
  Gets a identity by email and password.

  ## Examples

      iex> get_identity_by_email_and_password("foo@example.com", "correct_password")
      %Identity{}

      iex> get_identity_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_identity_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    identity = Repo.get_by(Identity, email: email)
    if Identity.valid_password?(identity, password), do: identity
  end

  @doc """
  Gets a single identity.

  Raises `Ecto.NoResultsError` if the Identity does not exist.

  ## Examples

      iex> get_identity!(123)
      %Identity{}

      iex> get_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_identity!(id), do: Repo.get!(Identity, id)

  ## Identity registration

  @doc """
  Registers a identity.

  ## Examples

      iex> register_identity(%{field: value})
      {:ok, %Identity{}}

      iex> register_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_identity(attrs) do
    %Identity{}
    |> Identity.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking identity changes.

  ## Examples

      iex> change_identity_registration(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_registration(%Identity{} = identity, attrs \\ %{}) do
    Identity.registration_changeset(identity, attrs)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the identity email.

  ## Examples

      iex> change_identity_email(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_email(identity, attrs \\ %{}) do
    Identity.email_changeset(identity, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_identity_email(identity, "valid password", %{email: ...})
      {:ok, %Identity{}}

      iex> apply_identity_email(identity, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_identity_email(identity, password, attrs) do
    identity
    |> Identity.email_changeset(attrs)
    |> Identity.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the identity email using the given token.

  If the token matches, the identity email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_identity_email(identity, token) do
    context = "change:#{identity.email}"

    with {:ok, query} <- IdentityToken.verify_change_email_token_query(token, context),
         %IdentityToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(identity_email_multi(identity, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp identity_email_multi(identity, email, context) do
    changeset = identity |> Identity.email_changeset(%{email: email}) |> Identity.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, changeset)
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, [context]))
  end

  @doc """
  Delivers the update email instructions to the given identity.

  ## Examples

      iex> deliver_update_email_instructions(identity, current_email, &Routes.identity_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Identity{} = identity, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "change:#{current_email}")

    Repo.insert!(identity_token)
    IdentityNotifier.deliver_update_email_instructions(identity, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the identity password.

  ## Examples

      iex> change_identity_password(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_password(identity, attrs \\ %{}) do
    Identity.password_changeset(identity, attrs)
  end

  @doc """
  Updates the identity password.

  ## Examples

      iex> update_identity_password(identity, "valid password", %{password: ...})
      {:ok, %Identity{}}

      iex> update_identity_password(identity, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_identity_password(identity, password, attrs) do
    changeset =
      identity
      |> Identity.password_changeset(attrs)
      |> Identity.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, changeset)
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{identity: identity}} -> {:ok, identity}
      {:error, :identity, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_identity_session_token(identity) do
    {token, identity_token} = IdentityToken.build_session_token(identity)
    Repo.insert!(identity_token)
    token
  end

  @doc """
  Gets the identity with the given signed token.
  """
  def get_identity_by_session_token(token) do
    {:ok, query} = IdentityToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(IdentityToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given identity.

  ## Examples

      iex> deliver_identity_confirmation_instructions(identity, &Routes.identity_confirmation_url(conn, :confirm, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_identity_confirmation_instructions(confirmed_identity, &Routes.identity_confirmation_url(conn, :confirm, &1))
      {:error, :already_confirmed}

  """
  def deliver_identity_confirmation_instructions(%Identity{} = identity, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if identity.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "confirm")
      Repo.insert!(identity_token)
      IdentityNotifier.deliver_confirmation_instructions(identity, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a identity by the given token.

  If the token matches, the identity account is marked as confirmed
  and the token is deleted.
  """
  def confirm_identity(token) do
    with {:ok, query} <- IdentityToken.verify_email_token_query(token, "confirm"),
         %Identity{} = identity <- Repo.one(query),
         {:ok, %{identity: identity}} <- Repo.transaction(confirm_identity_multi(identity)) do
      {:ok, identity}
    else
      _ -> :error
    end
  end

  defp confirm_identity_multi(identity) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, Identity.confirm_changeset(identity))
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given identity.

  ## Examples

      iex> deliver_identity_reset_password_instructions(identity, &Routes.identity_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_identity_reset_password_instructions(%Identity{} = identity, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "reset_password")
    Repo.insert!(identity_token)
    IdentityNotifier.deliver_reset_password_instructions(identity, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the identity by reset password token.

  ## Examples

      iex> get_identity_by_reset_password_token("validtoken")
      %Identity{}

      iex> get_identity_by_reset_password_token("invalidtoken")
      nil

  """
  def get_identity_by_reset_password_token(token) do
    with {:ok, query} <- IdentityToken.verify_email_token_query(token, "reset_password"),
         %Identity{} = identity <- Repo.one(query) do
      identity
    else
      _ -> nil
    end
  end

  @doc """
  Resets the identity password.

  ## Examples

      iex> reset_identity_password(identity, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Identity{}}

      iex> reset_identity_password(identity, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_identity_password(identity, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, Identity.password_changeset(identity, attrs))
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{identity: identity}} -> {:ok, identity}
      {:error, :identity, changeset, _} -> {:error, changeset}
    end
  end
end

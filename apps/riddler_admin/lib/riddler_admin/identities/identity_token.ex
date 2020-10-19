defmodule RiddlerAdmin.Identities.IdentityToken do
  use RiddlerAdmin.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "identities_tokens" do
    field :id, Ecto.UXID, primary_key: true, autogenerate: true, prefix: "idt", rand_size: 5
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :identity, RiddlerAdmin.Identities.Identity

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_session_token(identity) do
    token = :crypto.strong_rand_bytes(@rand_size)

    {token,
     %RiddlerAdmin.Identities.IdentityToken{
       token: token,
       context: "session",
       identity_id: identity.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity found by the token.
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: identity in assoc(token, :identity),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: identity

    {:ok, query}
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the identity email while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as identitys don't change
  their email.
  """
  def build_email_token(identity, context) do
    build_hashed_token(identity, context, identity.email)
  end

  defp build_hashed_token(identity, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %RiddlerAdmin.Identities.IdentityToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       identity_id: identity.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity found by the token.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: identity in assoc(token, :identity),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == identity.email,
            select: identity

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity token record.
  """
  def verify_change_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_and_context_query(token, context) do
    from RiddlerAdmin.Identities.IdentityToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given identity for the given contexts.
  """
  def identity_and_contexts_query(identity, :all) do
    from t in RiddlerAdmin.Identities.IdentityToken, where: t.identity_id == ^identity.id
  end

  def identity_and_contexts_query(identity, [_ | _] = contexts) do
    from t in RiddlerAdmin.Identities.IdentityToken,
      where: t.identity_id == ^identity.id and t.context in ^contexts
  end
end

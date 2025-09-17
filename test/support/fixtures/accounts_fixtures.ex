defmodule RiddlerAdmin.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RiddlerAdmin.Accounts` context.
  """

  import Ecto.Query

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Accounts.{Scope, UserToken}
  alias RiddlerAdmin.Repo

  @spec unique_user_email() :: String.t()
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  @spec valid_user_password() :: String.t()
  def valid_user_password, do: "hello world!"

  @spec valid_user_attributes(map()) :: map()
  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email()
    })
  end

  @spec unconfirmed_user_fixture(map()) :: Accounts.User.t()
  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  @spec user_fixture(map()) :: Accounts.User.t()
  def user_fixture(attrs \\ %{}) do
    user = unconfirmed_user_fixture(attrs)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_login_instructions(user, url)
      end)

    {:ok, {user, _expired_tokens}} =
      Accounts.login_user_by_magic_link(token)

    user
  end

  @spec user_scope_fixture() :: Scope.t()
  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  @spec user_scope_fixture(Accounts.User.t()) :: Scope.t()
  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  @spec set_password(Accounts.User.t()) :: Accounts.User.t()
  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  @spec extract_user_token((String.t() -> {:ok, map()})) :: String.t()
  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_prefix, token | _suffix] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @spec override_token_authenticated_at(String.t(), DateTime.t()) :: {integer(), nil | [term()]}
  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    Repo.update_all(
      from(t in UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  @spec generate_user_magic_link_token(Accounts.User.t()) :: {String.t(), String.t()}
  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  @spec offset_user_token(String.t(), integer(), System.time_unit()) ::
          {integer(), nil | [term()]}
  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(), amount_to_add, unit)

    Repo.update_all(
      from(ut in UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end

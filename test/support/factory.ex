defmodule RiddlerAdmin.Factory do
  @moduledoc """
  ExMachina factory for generating test data.
  """
  use ExMachina.Ecto, repo: RiddlerAdmin.Repo

  import Ecto.Query

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Accounts.{Scope, User, UserToken}
  alias RiddlerAdmin.Repo

  @valid_user_password "hello world!"

  @spec user_factory() :: User.t()
  def user_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com")
    }
  end

  @spec unconfirmed_user_factory() :: User.t()
  def unconfirmed_user_factory do
    build(:user)
  end

  @spec confirmed_user_factory() :: User.t()
  def confirmed_user_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      confirmed_at: DateTime.utc_now()
    }
  end

  @spec user_with_password_factory() :: User.t()
  def user_with_password_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      confirmed_at: DateTime.utc_now(),
      hashed_password: Argon2.hash_pwd_salt(@valid_user_password)
    }
  end

  @spec user_token_factory() :: UserToken.t()
  def user_token_factory do
    %UserToken{
      user: build(:user),
      token: :crypto.strong_rand_bytes(32),
      context: "session"
    }
  end

  @spec user_scope_factory() :: Scope.t()
  def user_scope_factory do
    %Scope{
      user: build(:user)
    }
  end

  # Helper functions equivalent to the old fixtures

  @spec valid_user_password() :: String.t()
  def valid_user_password, do: @valid_user_password

  @spec unique_user_email() :: String.t()
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  @spec valid_user_attributes(map()) :: map()
  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email()
    })
  end

  @spec set_password(User.t()) :: User.t()
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

  @spec generate_user_magic_link_token(User.t()) :: {String.t(), String.t()}
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

defmodule RiddlerAdmin.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RiddlerAdmin.Accounts` context.
  """

  def unique_identity_email, do: "identity#{System.unique_integer()}@example.com"
  def valid_identity_password, do: "hello world!"

  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        email: unique_identity_email(),
        password: valid_identity_password()
      })
      |> RiddlerAdmin.Accounts.register_identity()

    identity
  end

  def extract_identity_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end

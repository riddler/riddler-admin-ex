defmodule RiddlerAdminWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use RiddlerAdminWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  import RiddlerAdmin.Factory

  alias Phoenix.ConnTest
  alias Plug.Conn
  alias RiddlerAdmin.{Accounts, DataCase}
  alias RiddlerAdmin.Accounts.Scope

  using do
    quote do
      # The default endpoint for testing
      @endpoint RiddlerAdminWeb.Endpoint

      use RiddlerAdminWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import RiddlerAdminWeb.ConnCase
      import RiddlerAdmin.Factory
    end
  end

  setup tags do
    DataCase.setup_sandbox(tags)
    {:ok, conn: ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  @spec register_and_log_in_user(map()) :: map()
  def register_and_log_in_user(%{conn: conn} = context) do
    user = insert(:confirmed_user)
    scope = Scope.for_user(user)

    opts =
      context
      |> Map.take([:token_authenticated_at])
      |> Enum.into([])

    %{conn: log_in_user(conn, user, opts), user: user, scope: scope}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  @spec log_in_user(Conn.t(), struct(), keyword()) :: Conn.t()
  def log_in_user(conn, user, opts \\ []) do
    token = Accounts.generate_user_session_token(user)

    maybe_set_token_authenticated_at(token, opts[:token_authenticated_at])

    conn
    |> ConnTest.init_test_session(%{})
    |> Conn.put_session(:user_token, token)
  end

  @spec maybe_set_token_authenticated_at(String.t(), nil) :: nil
  defp maybe_set_token_authenticated_at(_token, nil), do: nil

  @spec maybe_set_token_authenticated_at(String.t(), DateTime.t()) :: :ok
  defp maybe_set_token_authenticated_at(token, authenticated_at) do
    override_token_authenticated_at(token, authenticated_at)
  end
end

defmodule RiddlerAdminWeb.Plugs.RequireSysadmin do
  @moduledoc """
  Plug to ensure the current user is a sysadmin.

  This plug requires user authentication to be complete and checks if the
  authenticated user has sysadmin privileges.
  """

  import Plug.Conn

  alias Phoenix.Controller
  alias RiddlerAdmin.Authorization
  alias RiddlerAdminWeb.ErrorHTML

  @doc """
  Initializes the plug with options.
  """
  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  @doc """
  Ensures the current user is a sysadmin.
  """
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      current_user when not is_nil(current_user) ->
        if Authorization.sysadmin?(current_user) do
          conn
        else
          conn
          |> put_status(:forbidden)
          |> Controller.put_view(ErrorHTML)
          |> Controller.render(:"403")
          |> halt()
        end

      nil ->
        # User not authenticated - this should not happen if authentication plug runs first
        conn
        |> put_status(:unauthorized)
        |> Controller.put_view(ErrorHTML)
        |> Controller.render(:"401")
        |> halt()
    end
  end
end

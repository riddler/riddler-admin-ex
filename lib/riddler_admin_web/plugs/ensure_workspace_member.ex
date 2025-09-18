defmodule RiddlerAdminWeb.Plugs.EnsureWorkspaceMember do
  @moduledoc """
  Plug to ensure the current user is a member of the loaded workspace.

  This plug requires both user authentication and workspace loading to be complete.
  It checks if the authenticated user has access to the workspace (either as a member or sysadmin).
  """

  import Plug.Conn

  alias Phoenix.Controller
  alias RiddlerAdmin.Authorization
  alias RiddlerAdmin.Workspaces.Workspace
  alias RiddlerAdminWeb.ErrorHTML

  @doc """
  Initializes the plug with options.
  """
  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  @doc """
  Ensures the current user is a member of the loaded workspace.
  """
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    with %Workspace{} = workspace <- conn.assigns[:workspace],
         current_user when not is_nil(current_user) <- conn.assigns[:current_user] do
      if Authorization.can_access_workspace?(current_user, workspace) do
        conn
      else
        conn
        |> put_status(:forbidden)
        |> Controller.put_view(ErrorHTML)
        |> Controller.render(:"403")
        |> halt()
      end
    else
      nil ->
        # Either workspace or user not loaded - this should not happen if plugs are ordered correctly
        conn
        |> put_status(:internal_server_error)
        |> Controller.put_view(ErrorHTML)
        |> Controller.render(:"500")
        |> halt()
    end
  end
end

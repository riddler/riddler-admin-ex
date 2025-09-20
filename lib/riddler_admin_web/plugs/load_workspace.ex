defmodule RiddlerAdminWeb.Plugs.LoadWorkspace do
  @moduledoc """
  Plug to load workspace from URL path parameter.

  This plug extracts the workspace_slug from the path parameters,
  loads the corresponding workspace, and adds it to the connection assigns.
  """

  import Plug.Conn

  alias Phoenix.Controller
  alias RiddlerAdmin.Accounts.Scope
  alias RiddlerAdmin.Workspaces
  alias RiddlerAdminWeb.ErrorHTML

  @doc """
  Initializes the plug with options.
  """
  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  @doc """
  Loads workspace from path parameter and assigns it to conn.
  """
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    case conn.path_params do
      %{"workspace_slug" => workspace_slug} when is_binary(workspace_slug) ->
        handle_workspace_slug(conn, workspace_slug)

      _other ->
        # No workspace_slug in path, continue without workspace
        conn
    end
  end

  defp handle_workspace_slug(conn, workspace_slug) do
    case Workspaces.get_workspace_by_slug(workspace_slug) do
      %Workspaces.Workspace{} = workspace ->
        load_workspace_into_conn(conn, workspace, workspace_slug)

      nil ->
        conn
        |> put_status(:not_found)
        |> Controller.put_view(ErrorHTML)
        |> Controller.render(:"404")
        |> halt()
    end
  end

  defp load_workspace_into_conn(conn, workspace, workspace_slug) do
    updated_scope =
      case conn.assigns[:current_scope] do
        %Scope{} = scope ->
          %{scope | workspace: workspace}

        nil ->
          %Scope{workspace: workspace}
      end

    conn
    |> assign(:workspace, workspace)
    |> assign(:workspace_slug, workspace_slug)
    |> assign(:current_scope, updated_scope)
  end
end

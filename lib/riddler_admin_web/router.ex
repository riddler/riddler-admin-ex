defmodule RiddlerAdminWeb.Router do
  use RiddlerAdminWeb, :router

  import RiddlerAdminWeb.UserAuth

  alias RiddlerAdminWeb.Plugs.{EnsureWorkspaceMember, LoadWorkspace, RequireSysadmin}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RiddlerAdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :workspace do
    plug LoadWorkspace
    plug EnsureWorkspaceMember
  end

  pipeline :admin do
    plug RequireSysadmin
  end

  scope "/", RiddlerAdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  ## Global workspace management (for workspace creation and switching)
  ## Note: These MUST come before the workspace_slug routes to avoid precedence conflicts
  scope "/", RiddlerAdminWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :workspace_management,
      on_mount: [{RiddlerAdminWeb.UserAuth, :require_authenticated}] do
      # Workspace selection/creation
      live "/workspaces", WorkspaceLive.Index, :index
      live "/workspaces/new", WorkspaceLive.New, :new

      # User dashboard (shows all workspaces)
      live "/dashboard", UserLive.Dashboard, :index
    end
  end

  ## Workspace routes
  scope "/workspaces/:workspace_slug", RiddlerAdminWeb do
    pipe_through [:browser, :require_authenticated_user, :workspace]

    live_session :workspace_required,
      on_mount: [{RiddlerAdminWeb.UserAuth, :require_authenticated}] do
      # Workspace dashboard
      live "/", WorkspaceLive.Dashboard, :index

      # Workspace settings
      live "/settings", WorkspaceLive.Settings, :edit
      live "/settings/members", WorkspaceLive.Members, :index
      live "/settings/members/invite", WorkspaceLive.Members, :invite

      # Member management
      live "/members/:id/edit", WorkspaceLive.Members, :edit_member
    end
  end

  ## Sysadmin routes (TODO: Implement admin LiveViews)
  # scope "/admin", RiddlerAdminWeb.Admin do
  #   pipe_through [:browser, :require_authenticated_user, :admin]

  #   live_session :admin_required,
  #     on_mount: [{RiddlerAdminWeb.UserAuth, :require_authenticated}] do
  #     live "/", AdminLive.Dashboard, :index
  #     live "/users", AdminLive.Users, :index
  #     live "/workspaces", AdminLive.Workspaces, :index
  #   end
  # end

  # Other scopes may use custom stacks.
  # scope "/api", RiddlerAdminWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:riddler_admin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RiddlerAdminWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", RiddlerAdminWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RiddlerAdminWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", RiddlerAdminWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{RiddlerAdminWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end

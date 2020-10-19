defmodule RiddlerAdminWeb.Router do
  use RiddlerAdminWeb, :router

  import RiddlerAdminWeb.IdentityAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RiddlerAdminWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_identity
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RiddlerAdminWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiddlerAdminWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: RiddlerAdminWeb.Telemetry,
        ecto_repos: [RiddlerAdmin.Repo]
    end
  end

  ## Authentication routes

  scope "/", RiddlerAdminWeb do
    pipe_through [:browser, :redirect_if_identity_is_authenticated]

    get "/identities/register", IdentityRegistrationController, :new
    post "/identities/register", IdentityRegistrationController, :create
    get "/identities/log_in", IdentitySessionController, :new
    post "/identities/log_in", IdentitySessionController, :create
    get "/identities/reset_password", IdentityResetPasswordController, :new
    post "/identities/reset_password", IdentityResetPasswordController, :create
    get "/identities/reset_password/:token", IdentityResetPasswordController, :edit
    put "/identities/reset_password/:token", IdentityResetPasswordController, :update
  end

  scope "/", RiddlerAdminWeb do
    pipe_through [:browser, :require_authenticated_identity]

    get "/identities/settings", IdentitySettingsController, :edit
    put "/identities/settings/update_password", IdentitySettingsController, :update_password
    put "/identities/settings/update_email", IdentitySettingsController, :update_email
    get "/identities/settings/confirm_email/:token", IdentitySettingsController, :confirm_email

    resources "/accounts", AccountController do
      get "/switch", AccountSwitchController, :switch
    end

    resources "/workspaces", WorkspaceController do
      get "/switch", WorkspaceSwitchController, :switch
    end
  end

  scope "/", RiddlerAdminWeb do
    pipe_through [:browser]

    delete "/identities/log_out", IdentitySessionController, :delete
    get "/identities/confirm", IdentityConfirmationController, :new
    post "/identities/confirm", IdentityConfirmationController, :create
    get "/identities/confirm/:token", IdentityConfirmationController, :confirm
  end
end

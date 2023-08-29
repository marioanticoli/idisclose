defmodule IdiscloseWeb.Router do
  use IdiscloseWeb, :router

  import IdiscloseWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {IdiscloseWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", IdiscloseWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", IdiscloseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard 
  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through [:browser, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [{IdiscloseWeb.UserAuth, :ensure_authenticated}] do
      # Users 
      live("/users", UserLive.Index, :index)
      live("/users/:id/edit", UserLive.Index, :edit)

      live("/users/:id", UserLive.Show, :show)
      live("/users/:id/show/edit", UserLive.Show, :edit)
    end

    live_dashboard("/dashboard", metrics: IdiscloseWeb.Telemetry, ecto_repos: [Idisclose.Repo])
  end

  ## Authentication routes

  scope "/", IdiscloseWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{IdiscloseWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", IdiscloseWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{IdiscloseWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # Templates
      live("/templates", TemplateLive.Index, :index)
      live("/templates/new", TemplateLive.Index, :new)
      live("/templates/:id/edit", TemplateLive.Index, :edit)

      live("/templates/:id", TemplateLive.Show, :show)
      live("/templates/:id/show/edit", TemplateLive.Show, :edit)
      live("/templates/:id/section", TemplateLive.Show, :new_assoc)

      # Sections 
      live("/sections", SectionLive.Index, :index)
      live("/sections/new", SectionLive.Index, :new)
      live("/sections/:id/edit", SectionLive.Index, :edit)

      live("/sections/:id", SectionLive.Show, :show)
      live("/sections/:id/show/edit", SectionLive.Show, :edit)

      # Documents
      live "/documents", DocumentLive.Index, :index
      live "/documents/new", DocumentLive.Index, :new
      live "/documents/:id/edit", DocumentLive.Index, :edit

      live "/documents/:id", DocumentLive.Show, :show
      live "/documents/:id/show/edit", DocumentLive.Show, :edit

      live "/documents/:id/chapter/:chapter_id", DocumentLive.Editor, :edit

      live "/documents/:id/chapter/:chapter_id/compare", DocumentLive.Version, :compare
    end
  end

  scope "/", IdiscloseWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{IdiscloseWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end

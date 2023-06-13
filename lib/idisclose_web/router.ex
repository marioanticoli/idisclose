defmodule IdiscloseWeb.Router do
  use IdiscloseWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {IdiscloseWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", IdiscloseWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

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
    live "/documents/:id/chapter/:chapter_id", DocumentLive.Show, :editor
    # live "/documents/:id/chapter/new", DocumentLive.Show, :new_chapter
  end

  # Other scopes may use custom stacks.
  # scope "/api", IdiscloseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:idisclose, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: IdiscloseWeb.Telemetry)
    end
  end
end

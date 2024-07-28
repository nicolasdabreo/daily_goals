defmodule DailyGoalsWeb.Router do
  use DailyGoalsWeb, :router

  alias DailyGoalsWeb.Persona

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DailyGoalsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Persona
  end

  scope "/", DailyGoalsWeb do
    pipe_through :browser

    live_session :application, on_mount: [Persona] do
      live "/", GoalsLive, :index
      live "/:date", GoalsLive, :index
      live "/reports", ReportsLive, :index
      live "/reports/:date", ReportsLive, :index
    end
  end
end

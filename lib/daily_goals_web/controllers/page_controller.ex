defmodule DailyGoalsWeb.PageController do
  use DailyGoalsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

defmodule DailyGoalsWeb.ReportsLive do
  use DailyGoalsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    date = params["date"] || Date.to_string(Date.utc_today())
    {:ok, date} = Date.from_iso8601(date)
    next_date = Date.add(date, 1)
    prev_date = Date.add(date, -1)

    {:noreply,
     socket
     |> assign(:date, date)
     |> assign(:next_date, next_date)
     |> assign(:previous_date, prev_date)}
  end
end

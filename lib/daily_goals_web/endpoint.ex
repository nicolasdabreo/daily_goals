defmodule DailyGoalsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :daily_goals

  @session_options [
    store: :cookie,
    key: "_daily_goals_key",
    signing_salt: "K8NTgXOT",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :daily_goals,
    gzip: false,
    only: DailyGoalsWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug DailyGoalsWeb.Router
end

import Config

config :daily_goals, DailyGoalsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8auU2Vkjbb5Jj/xEDwUmtIquDwH7W/DnQa0+hhVPkQgIcoIdhV2dVzYYUpaSGI6Y",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

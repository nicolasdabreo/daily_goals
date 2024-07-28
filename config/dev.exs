import Config

config :daily_goals, DailyGoalsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "bDTseaRuWAxkWpEowLRdGHWrBAioRfmvrGhjRjEm3jV/ftWtN2AWNt4gYhath8vS",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:daily_goals, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:daily_goals, ~w(--watch)]}
  ]

config :daily_goals, DailyGoalsWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/daily_goals_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :daily_goals, dev_routes: true
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true

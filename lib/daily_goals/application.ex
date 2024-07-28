defmodule DailyGoals.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DailyGoalsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:daily_goals, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DailyGoals.PubSub},
      # Start a worker by calling: DailyGoals.Worker.start_link(arg)
      # {DailyGoals.Worker, arg},
      # Start to serve requests, typically the last entry
      DailyGoalsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DailyGoals.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DailyGoalsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

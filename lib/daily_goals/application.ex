defmodule DailyGoals.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:daily_goals, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DailyGoals.PubSub},
      DailyGoalsWeb.Endpoint
    ]

    DailyGoals.Goals.init_table()
    opts = [strategy: :one_for_one, name: DailyGoals.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DailyGoalsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

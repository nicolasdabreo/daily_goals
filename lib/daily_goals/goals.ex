defmodule DailyGoals.Goals do
  alias :ets, as: ETS
  alias __MODULE__.Goal

  defp topic, do: "goals"
  def subscribe, do: Phoenix.PubSub.subscribe(DailyGoals.PubSub, topic())
  def broadcast(event), do: Phoenix.PubSub.broadcast(DailyGoals.PubSub, topic(), event)

  def init_table, do: ETS.new(:goals, [:duplicate_bag, :public, :named_table, read_concurrency: true])

  def create_goal(persona_id, params) do
    goal = %{id: unique_id(), persona_id: persona_id, goal_text: params["goal_text"], completed_at: nil}
    ETS.insert(:goals, {persona_id, goal})
    broadcast({:goal_created, goal})
    :ok
  end

  def list_goals(persona_id) do
    ETS.lookup(:goals, persona_id)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reverse()
  end

  def change_goal(goal = %Goal{}, params) do
    Goal.changeset(goal, params)
  end

  defp unique_id, do: System.unique_integer([:positive, :monotonic])
end

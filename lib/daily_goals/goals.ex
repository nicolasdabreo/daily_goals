defmodule DailyGoals.Goals do
  alias :ets, as: ETS
  alias __MODULE__.Goal

  defp topic, do: "goals"
  def subscribe, do: Phoenix.PubSub.subscribe(DailyGoals.PubSub, topic())
  def broadcast(event), do: Phoenix.PubSub.broadcast(DailyGoals.PubSub, topic(), event)

  def init_table, do: ETS.new(:goals, [:set, :public, :named_table, read_concurrency: true])

  def create_goal(persona_id, params) do
    goal_id = unique_id()
    today = Date.utc_today()

    steps =
      case Integer.parse(params["steps"]) do
        {steps, _} ->
          steps

        _ ->
          0
      end

    goal = %Goal{
      id: goal_id,
      persona_id: persona_id,
      goal_text: params["goal_text"],
      steps: steps,
      progress: 0,
      completed_at: nil,
      creation_date: today
    }

    ETS.insert(:goals, {goal_id, today, goal})
    broadcast({:goal_created, goal})
    goal
  end

  def list_goals(date) do
    match_spec = [{{:_, date, :_}, [], [:"$_"]}]

    ETS.select(:goals, match_spec)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 2))
    |> Enum.reverse()
  end

  def get_goal(id) do
    ETS.lookup(:goals, id)
  end

  def update_goal_progress(%Goal{steps: steps} = goal, progress) when steps == progress do
    update_goal(%{goal | progress: progress, completed_at: DateTime.utc_now()})
  end

  def update_goal_progress(%Goal{steps: steps} = goal, progress) when not is_nil(steps) do
    update_goal(%{goal | progress: progress})
  end

  def toggle_goal_completion(%Goal{completed_at: nil, steps: steps, progress: progress} = goal) when progress < steps do
    update_goal(%{goal | completed_at: DateTime.utc_now(), progress: steps})
  end

  def toggle_goal_completion(%Goal{completed_at: nil} = goal) do
    update_goal(%{goal | completed_at: DateTime.utc_now()})
  end

  def toggle_goal_completion(%Goal{steps: steps, progress: progress, completed_at: _completed_at = %DateTime{}} = goal) when steps == progress do
    update_goal(%{goal | completed_at: nil, progress: steps - 1})
  end

  def toggle_goal_completion(%Goal{completed_at: _completed_at = %DateTime{}} = goal) do
    update_goal(%{goal | completed_at: nil})
  end

  defp update_goal(goal) do
    ETS.delete(:goals, goal.id)
    ETS.insert(:goals, {goal.id, goal.creation_date, goal})
    broadcast({:goal_updated, goal})
    goal
  end

  def change_goal(goal = %Goal{}, params) do
    Goal.changeset(goal, params)
  end

  defp unique_id, do: System.unique_integer([:positive, :monotonic])
end

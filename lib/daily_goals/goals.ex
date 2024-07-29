defmodule DailyGoals.Goals do
  alias :ets, as: ETS
  alias __MODULE__.Goal

  defp topic, do: "goals"
  def subscribe, do: Phoenix.PubSub.subscribe(DailyGoals.PubSub, topic())
  def broadcast(event), do: Phoenix.PubSub.broadcast(DailyGoals.PubSub, topic(), event)

  @doc "Sets up an ETS table for us to use, this is run on Application startup"
  def init_table, do: ETS.new(:goals, [:set, :public, :named_table, read_concurrency: true])

  @doc "Creates a goal tuple under the goal_id, also stores the date for use in match specs"
  def create_goal(persona_id, params, date \\ Date.utc_today()) do
    goal_id = unique_id()

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
      creation_date: date
    }

    ETS.insert(:goals, {goal_id, date, goal})
    broadcast({:goal_created, goal})
    goal
  end

  @doc "Retrieves all goals for the given date, using the match spec to match the dates"
  def list_goals(date) do
    match_spec = [{{:_, date, :_}, [], [:"$_"]}]

    ETS.select(:goals, match_spec)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 2))
    |> Enum.reverse()
  end

  @doc "Retrieves a goal from the table by its ID"
  def get_goal(id) do
    ETS.lookup(:goals, id)
  end

  @doc "Updates the progress of a goal through its numerical steps"
  def update_goal_progress(%Goal{steps: steps} = goal, progress) when steps == progress do
    update_goal(%{goal | progress: progress, completed_at: DateTime.utc_now()})
  end

  def update_goal_progress(%Goal{steps: steps} = goal, progress) when not is_nil(steps) do
    update_goal(%{goal | progress: progress})
  end

  @doc """
  Toggles the completion state of a Goal by changing its completed at to the current date,
  or by nilifying it.

  This has some side-effects for numerical goals to improve UX, a completed goal will have its
  progress maxed, an incomplete goal will have its progress reverted to one number before max.
  """
  def toggle_goal_completion(%Goal{completed_at: nil, steps: steps, progress: progress} = goal)
      when progress < steps do
    update_goal(%{goal | completed_at: DateTime.utc_now(), progress: steps})
  end

  def toggle_goal_completion(%Goal{completed_at: nil} = goal) do
    update_goal(%{goal | completed_at: DateTime.utc_now()})
  end

  def toggle_goal_completion(
        %Goal{steps: steps, progress: progress, completed_at: _completed_at = %DateTime{}} = goal
      )
      when steps == progress do
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

  @seed_goals [
    %{"goal_text" => "Call mum", "steps" => ""},
    %{"goal_text" => "Learn Polish for 10 minutes", "steps" => "10"},
    %{"goal_text" => "Finish reading a book", "steps" => ""},
    %{"goal_text" => "Write a blog post", "steps" => "5"},
    %{"goal_text" => "Go for a run", "steps" => "5"},
    %{"goal_text" => "Prepare a presentation", "steps" => "3"},
    %{"goal_text" => "Clean the house", "steps" => "3"},
    %{"goal_text" => "Complete Elixir project", "steps" => ""},
    %{"goal_text" => "Meditate", "steps" => "1"},
    %{"goal_text" => "Cook dinner", "steps" => "3"},
    %{"goal_text" => "Organize workspace", "steps" => ""},
    %{"goal_text" => "Plan vacation", "steps" => "4"},
    %{"goal_text" => "Update resume", "steps" => "2"},
    %{"goal_text" => "Practice guitar", "steps" => "1"},
    %{"goal_text" => "Read an article", "steps" => ""},
    %{"goal_text" => "Grocery shopping", "steps" => "2"},
    %{"goal_text" => "Water plants", "steps" => ""},
    %{"goal_text" => "Fix the bike", "steps" => "2"},
    %{"goal_text" => "Learn a new recipe", "steps" => "3"},
    %{"goal_text" => "Call a friend", "steps" => ""}
  ]

  @doc """
  Generates some random seed data for testing
  """
  def generate_seed_data(persona_id, date) do
    for _i <- 1..Enum.random(2..10), do: create_goal(persona_id, Enum.random(@seed_goals), date)
  end

  def change_goal(goal = %Goal{}, params) do
    Goal.changeset(goal, params)
  end

  defp unique_id, do: System.unique_integer([:positive, :monotonic])
end

defmodule DailyGoals.Goals.Goal do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__, as: Goal

  embedded_schema do
    field(:persona_id, :string)
    field(:goal_text, :string)
    field(:completed_at, :utc_datetime)
  end

  def changeset(goal = %Goal{}, params) do
    goal
    |> cast(params, [])
    |> validate_required([])
  end
end

defmodule DailyGoalsWeb.GoalsLiveTest do
  use DailyGoalsWeb.ConnCase

  alias DailyGoals.Persona
  alias DailyGoals.Goals

  describe "Goals page" do
    setup [:with_a_persona, :and_some_set_goals]

    test "creates and displays todays goals", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("#goals-form", goal: %{goal_text: "Goalie McGoalFace"})
        |> render_submit()

      assert html =~ "Goalie McGoalFace"
    end

    test "goals can be marked as completed", %{conn: conn, goals: [goal | _rest]} do
      {:ok, view, html} = live(conn, ~p"/")

      refute html =~ "Completed at"

      view
      |> element("#goals-#{goal.id}")
      |> render_click()
    end

    test "allows the creation of goals with numerical progress" do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("#goals-form", goal: %{goal_text: "Sets of pushups", steps: 10})
        |> render_submit()

      assert html =~ "Goalie McGoalFace"
    end
  end

  defp with_a_persona(context) do
    persona = Persona.generate_persona()
    conn = Plug.Test.init_test_session(context.conn, %{persona_id: persona.id, persona_name: persona.name, persona_emoji: persona.emoji})

    context
    |> Map.put(:persona, persona)
    |> Map.put(:conn, conn)
  end

  defp and_some_set_goals(context) do
    goals = for i <- 1..Enum.random(1..5), do: Goals.create_goal(context.persona.id, %{"goal_text" => "Goal #{i}"})

    context
    |> Map.put(:goals, goals)
  end
end

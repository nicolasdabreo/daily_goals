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
        |> form("#goals-form", goal: %{goal_text: "Do 20 pushups"})
        |> render_submit()

      assert html =~ "Do 20 pushups"
    end

    test "goals can be marked as completed", %{conn: conn, goals: [goal | _rest]} do
      {:ok, view, html} = live(conn, ~p"/")

      refute html =~ "Completed on"

      html =
        view
        |> element("#goals-#{goal.id}-complete-button")
        |> render_click()

      assert html =~ "Completed on"
    end

    test "allows the creation of goals with numerical progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Create the goal
      view
      |> form("#goals-form", goal: %{goal_text: "Sets of pushups", steps: 10})
      |> render_submit()

      goal = Goals.list_goals(Date.utc_today()) |> List.first()

      # Change the goal's progress
      view
      |> form("#progress-form-#{goal.id}", %{progress: 5})
      |> render_change()

      # Check that the goal's progress changed
      assert element(view, "##{goal.id}-progress", "step-#{goal.progress}")
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
    goals = for i <- 1..Enum.random(1..5), do: Goals.create_goal(context.persona.id, %{"goal_text" => "Goal #{i}", "steps" => ""})

    context
    |> Map.put(:goals, goals)
  end
end

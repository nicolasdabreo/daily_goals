defmodule DailyGoalsWeb.GoalsLive do
  use DailyGoalsWeb, :live_view

  alias DailyGoals.Goals
  alias DailyGoals.Goals.Goal

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Goals.subscribe()
    end

    {:ok,
     socket
     |> assign_form(%Goal{})
     |> stream(:goals, Goals.list_goals(socket.assigns.persona.id))}
  end

  def handle_event("validate", %{"goal" => goal_params}, socket) do
    {:noreply, assign_form(socket, %Goal{}, goal_params)}
  end

  def handle_event("save", %{"goal" => goal_params}, socket) do
    Goals.create_goal(socket.assigns.persona.id, goal_params)

    {:noreply,
     socket
     |> assign_form(%Goal{})
     |> put_flash(:info, "New goal created!")}
  end

  def handle_event("toggle-goal", %{"id" => id}, socket) do
    id
    |> String.to_integer()
    |> Goals.get_goal()
    |> case do
      [] ->
        {:noreply, put_flash(socket, :error, "Goal not found")}

      [{_, _, goal = %Goal{}}] ->
        Goals.toggle_goal_completion(goal)

        {:noreply,
         socket
         |> stream_insert(:goals, goal)}
    end
  end

  def handle_info({:goal_created, goal}, socket) do
    {:noreply, stream_insert(socket, :goals, goal, at: 0)}
  end

  def handle_info({:goal_updated, goal}, socket) do
    {:noreply, stream_insert(socket, :goals, goal)}
  end

  defp assign_form(socket, goal, params \\ %{}) do
    form =
      goal
      |> Goals.change_goal(params)
      |> to_form(action: :validate)

    assign(socket, :form, form)
  end

  defp humanize_date(datetime) do
    NaiveDateTime.to_date(datetime) |> Calendar.strftime("%d-%m-%Y")
  end
end

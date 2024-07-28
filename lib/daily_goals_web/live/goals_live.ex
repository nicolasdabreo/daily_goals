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
    {:noreply, assign_form(socket, %Goal{})}
  end

  def handle_info({:goal_created, goal}, socket) do
    {:noreply, stream_insert(socket, :goals, goal)}
  end

  defp assign_form(socket, goal, params \\ %{}) do
    form =
      goal
      |> Goals.change_goal(params)
      |> to_form(action: :validate)

    assign(socket, :form, form)
  end
end

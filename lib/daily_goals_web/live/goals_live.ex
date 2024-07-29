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
     |> stream(:goals, [])}
  end

  def handle_params(params, _uri, socket) do
    date = params["date"] || Date.to_string(Date.utc_today())
    {:ok, date} = Date.from_iso8601(date)
    next_date = Date.add(date, 1)
    prev_date = Date.add(date, -1)

    {:noreply,
      socket
      |> assign(:date, date)
      |> assign(:next_date, next_date)
      |> assign(:previous_date, prev_date)
      |> stream(:goals, Goals.list_goals(date))}
  end

  def handle_event("validate", %{"goal" => goal_params}, socket) do
    {:noreply, assign_form(socket, %Goal{}, goal_params)}
  end

  def handle_event("save", %{"goal" => goal_params}, socket) do
    goal = Goals.create_goal(socket.assigns.persona.id, goal_params)

    {:noreply,
     socket
     |> assign_form(%Goal{})
     |> stream_insert(:goals, goal, at: 0)
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

        {:noreply, stream_insert(socket, :goals, goal)}
    end
  end

  def handle_event("update-progress", %{"id" => id, "progress" => progress}, socket) do
    progress = String.to_integer(progress)
    [{_, _, goal = %Goal{}}] = String.to_integer(id) |> Goals.get_goal()
    Goals.update_goal_progress(goal, progress)

    {:noreply, stream_insert(socket, :goals, goal)}
  end

  def handle_event("generate-data", _params, socket) do
    Goals.generate_seed_data(socket.assigns.persona.id, socket.assigns.date)
    {:noreply, socket}
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

  def goal(assigns) do
    ~H"""
    <li
      id={@id}
      class="flex items-center group hover:bg-zinc-50 justify-between gap-x-6 py-5 rounded-lg p-4 min-h-40"
    >
      <div class="w-full">
        <div class="flex items-start gap-x-3">
          <p class={[
            "text-lg font-semibold leading-6 text-zinc-700 truncate",
            @goal.completed_at && "line-through"
          ]}>
            <%= @goal.goal_text %>
            <%= if @goal.steps > 1 do %>
              <%= @goal.progress %> / <%= @goal.steps %>
            <% end %>
          </p>
        </div>
        <div class="mt-1 flex flex-col space-y-2 leading-5 text-zinc-500">
          <div class="flex flex-row items-center gap-x-2 text-xs">
            <p class="truncate">
              Created by <span class="sr-only"><%= @persona.name %></span>
              <.tooltip>
                <DailyGoalsWeb.Layouts.avatar persona={@persona} />
                <.tooltip_content>
                  <%= @persona.name %>
                </.tooltip_content>
              </.tooltip>
            </p>
          </div>
          <%= if @goal.completed_at do %>
            <p class="whitespace-nowrap text-sm">
              Completed at
              <time datetime={@goal.completed_at}><%= humanize_date(@goal.completed_at) %></time>
            </p>
          <% else %>
            <%= if @goal.steps > 1 do %>
              <div class="w-full">
                <form id={"progress-form-#{@goal.id}"} phx-change="update-progress" phx-value-id={@goal.id} class="w-full">
                  <input id={"#{@goal.id}-progress"} data-value={"step-#{@goal.progress}"} name="progress" id={"#{@id}-#{@goal.id}-slider"} type="range" min="0" max={@goal.steps} step="1" value={@goal.progress} class="w-full" />
                  <div class="flex justify-between mt-2 text-sm font-medium text-gray-700">
                    <span>0</span>
                    <span><%= @goal.steps %></span>
                  </div>
                </form>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
      <div class="flex flex-none items-center gap-x-4 text-zinc-400">
        <.button
          id={"goals-#{@id}-complete-button"}
          size="icon"
          variant="ghost"
          phx-click="toggle-goal"
          phx-value-id={@goal.id}
          class={[
            "focus:ring-0 focus:ring-offset-0 ",
            @goal.completed_at && "text-emerald-500 group-hover:text-emerald-600"
          ]}
        >
          <span class="sr-only">Toggle completion</span>
          <.icon name="hero-check-circle" class="h-8 w-8" />
        </.button>
      </div>
    </li>
    """
  end
end

defmodule DailyGoalsWeb.Layouts do
  use DailyGoalsWeb, :html

  embed_templates "layouts/*"

  def avatar(assigns) do
    ~H"""
    <div class="flex -space-x-2 isolate">
      <div class="z-0 inline-block w-8 h-8 rounded-full cursor-pointer bg-zinc-50">
        <span class="flex items-center justify-center w-full h-full text-xl">
          <%= @persona.emoji %>
        </span>
      </div>
    </div>
    """
  end
end

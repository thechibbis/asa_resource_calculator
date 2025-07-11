defmodule AsaResourceCalculatorWeb.HomeLive do
  use AsaResourceCalculatorWeb, :live_view

  def render(assigns) do
    ~H"""
    <main class="h-screen flex flex-col items-start gap-4 p-8 bg-base-200">
      <div class="flex justify-center w-full gap-4">
        <h1 class="text-3xl">ASA Resource Calculator</h1>
        <Layouts.theme_toggle />
      </div>

      <div class="card border border-base-300 max-w-sm bg-base-100 flex-1 min-h-0">
        <div class="card-body overflow-y-auto">
          <h2 class="card-title">items</h2>
          <ul class="list">
            <%= for item <- @items do %>
              <li class="list-row py-1">{item["name"]}</li>
            <% end %>
          </ul>
        </div>
      </div>
    </main>
    """
  end

  def mount(_params, _session, socket) do
    items = AsaResourceCalculator.Cache.get_all_items()

    {:ok, socket |> assign(:items, items)}
  end
end

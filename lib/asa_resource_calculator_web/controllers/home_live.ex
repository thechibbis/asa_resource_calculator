defmodule AsaResourceCalculatorWeb.HomeLive do
  use AsaResourceCalculatorWeb, :live_view

  def render(assigns) do
    ~H"""
    <main class="h-screen flex flex-col items-start gap-4 p-8 pt-2 bg-base-200">
      <div class="flex justify-center w-full gap-4">
        <h1 class="text-3xl">ASA Resource Calculator</h1>
        <Layouts.theme_toggle />
      </div>

      <div class="flex flex-1 flow-col min-h-0 gap-4 w-full">
        <div class="card border border-base-300 bg-base-100 ">
          <div class="card-body overflow-y-auto p-4">
            <div>
              <.form for={@form} phx-change="search_item">
                <.input
                  type="text"
                  name="search"
                  placeholder="Search..."
                  field={@form[:search_item]}
                  class="border-none "
                />
              </.form>
            </div>

            <ul class="list">
              <%= for item <- @items do %>
                <%= if String.downcase((item["name"])) |> String.contains?(@search_item) do %>
                  <li class="list-row flex justify-between items-center gap-4 p-0 py-4">
                    <div>
                      <.icon name="hero-building-office" />
                      {item["name"]}
                    </div>
                    <button phx-click="add-item" class="btn btn-primary btn-ghost btn-sm btn-square">
                      <.icon name="hero-plus" />
                    </button>
                  </li>
                <% end %>
              <% end %>
            </ul>
          </div>
        </div>

        <div class="card border border-base-300 bg-base-100 w-full"></div>
      </div>
    </main>
    """
  end

  def mount(_params, _session, socket) do
    items = AsaResourceCalculator.Cache.get_all_items()

    {:ok,
     socket
     |> assign(:items, items)
     |> assign(:form, to_form(%{"search_item" => ""}))
     |> assign(:search_item, "")}
  end

  def handle_event("search_item", %{"search" => item_name}, socket) do
    {:noreply, socket |> assign(:search_item, String.downcase(item_name))}
  end
end

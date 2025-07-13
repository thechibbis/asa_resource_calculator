defmodule AsaResourceCalculatorWeb.HomeLive do
  use AsaResourceCalculatorWeb, :live_view

  def render(assigns) do
    ~H"""
    <main class="h-screen flex flex-col items-start gap-4 p-8 pt-2 bg-base-200">
      <div class="flex justify-center w-full gap-4">
        <h1 class="text-3xl">ASA Resource Calculator</h1>
        <Layouts.theme_toggle />
      </div>

      <div class="flex flex-1 flow-col min-h-0 gap-2 w-full">
        <div class="card border border-base-300 bg-base-100 min-w-90">
          <div class="card-body overflow-y-auto p-4">
            <div>
              <.form for={@form} phx-change="search-item">
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
              <li
                :for={item <- @items}
                :if={String.downcase(item["name"]) |> String.contains?(@search_item)}
                class="list-row flex justify-between items-center gap-4 p-0 py-4"
              >
                <div class="flex flex-row gap-2 items-center">
                  <img src={item["icon_url"]} alt={item["name"]} width="32" height="32" />
                  {item["name"]}:
                </div>
                <button
                  phx-click="add-item"
                  value={item["name"]}
                  class="btn btn-primary btn-ghost btn-sm btn-square"
                >
                  <.icon name="hero-plus" />
                </button>
              </li>
            </ul>
          </div>
        </div>

        <div class="card border border-base-300 bg-base-100 w-full overflow-y-auto">
          <button phx-click="reset-added-items" class="btn btn-error">reset</button>
          <ul class="list">
            <li
              :for={item <- @added_items}
              class="list-row flex justify-between items-center gap-4 p-4 py-4"
            >
              <div class="flex flex-row gap-4 items-center">
                <div class="flex flex-row gap-2 items-center">
                  <img src={item["icon_url"]} alt={item["name"]} width="32" height="32" />
                  {item["name"]}:
                </div>

                <div class="flex flex-row gap-4 text-center">
                  <p :for={resource <- item["resources"]}>
                    <img src={resource["icon_url"]} alt={resource["name"]} /> {resource[
                      "quantity"
                    ]}
                  </p>
                </div>
              </div>
            </li>
          </ul>
        </div>
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
     |> assign(:search_item, "")
     |> assign(:added_items, [])}
  end

  def handle_event("search-item", %{"search" => item_name}, socket) do
    {:noreply, socket |> assign(:search_item, String.downcase(item_name))}
  end

  def handle_event("add-item", %{"value" => item_name}, socket) do
    item = Enum.find(socket.assigns.items, fn item -> item["name"] == item_name end)

    {:noreply, socket |> assign(:added_items, [item | socket.assigns.added_items])}
  end

  def handle_async("reset-added-items", _params, socket) do
    {:noreply, socket |> assign(:added_items, [])}
  end
end

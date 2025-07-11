defmodule AsaResourceCalculator.Cache do
  @moduledoc """
  Module responsible for caching the scrapped data into a ETS table.
  """

  use GenServer

  @items_table :items_cache
  @data_filename "AsaResourceCalculator.Scrapper_840b4dea-5dca-11f0-ba02-00155d284262.jl"

  def start_link(_opts) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def get_all_items do
    items =
      :ets.tab2list(@items_table)
      |> Enum.map(fn {_, value} -> value end)

    items
  end

  @impl true
  def init(_opts) do
    :ets.new(@items_table, [:set, :protected, :named_table, read_concurrency: true])
    load_data_into_ets()
    {:ok, %{}}
  end

  defp load_data_into_ets do
    Application.app_dir(:asa_resource_calculator, "priv")
    |> Path.join("data/" <> @data_filename)
    |> load_from_file()
    |> Enum.each(fn i ->
      :ets.insert(@items_table, {i["name"], i})
    end)
  end

  defp load_from_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&Jason.decode!/1)
  end
end

defmodule AsaResourceCalculator.Scrapper do
  @moduledoc """
  Module responsible for scrapping the ark.wiki.gg
  iex> Crawly.Engine.start_spider(AsaResourceCalculator.Scrapper)
  """

  use Crawly.Spider

  @impl Crawly.Spider
  def base_url, do: "https://ark.wiki.gg/"

  @impl Crawly.Spider
  def init do
    [
      start_urls: [
        "https://ark.wiki.gg/wiki/Structures",
        "https://ark.wiki.gg/wiki/Resources"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    item_card = Floki.find(document, ".info-framework")

    item = %{
      id: UUID.uuid4(),
      name: item_card |> Floki.find("div .info-masthead") |> Floki.text(),
      resources:
        item_card
        |> Floki.find("div[style*='padding-left:5px'] b")
        |> Enum.map(fn x ->
          %{
            name:
              Floki.find(x, "a:has(img)")
              |> Floki.attribute("title")
              |> Floki.text()
              |> parse_name(),
            quantity:
              elem(x, 2)
              |> Floki.text()
              |> String.split(" × ")
              |> List.first(),
            icon_url:
              Floki.find(x, "a:has(img) img")
              |> Floki.attribute("src")
              |> Floki.text()
          }
        end)
        |> parse_resources()
    }

    next_requests =
      document
      |> Floki.find("table[class*=cargo-item-table] tbody tr a[href]")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        Crawly.Utils.build_absolute_url(url, response.request.url)
        |> Crawly.Utils.request_from_url()
      end)

    %Crawly.ParsedItem{:items => [item], :requests => next_requests}
  end

  @spec parse_name(binary()) :: binary()
  defp parse_name(name) when is_binary(name) do
    case String.contains?(name, ["Primitive Plus", "Mobile"]) do
      true -> ""
      false -> name
    end
  end

  @spec parse_resources(list()) :: list()
  defp parse_resources(res) do
    case Enum.empty?(res) do
      true -> nil
      false -> res
    end
  end
end

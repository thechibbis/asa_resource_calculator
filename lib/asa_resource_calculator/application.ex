defmodule AsaResourceCalculator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AsaResourceCalculatorWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:asa_resource_calculator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AsaResourceCalculator.PubSub},
      # Start a worker by calling: AsaResourceCalculator.Worker.start_link(arg)
      # {AsaResourceCalculator.Worker, arg},
      # Start to serve requests, typically the last entry
      AsaResourceCalculatorWeb.Endpoint,
      AsaResourceCalculator.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AsaResourceCalculator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AsaResourceCalculatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

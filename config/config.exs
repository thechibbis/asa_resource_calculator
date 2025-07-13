# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :asa_resource_calculator,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :asa_resource_calculator, AsaResourceCalculatorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AsaResourceCalculatorWeb.ErrorHTML, json: AsaResourceCalculatorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AsaResourceCalculator.PubSub,
  live_view: [signing_salt: "IJs3iKBX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  asa_resource_calculator: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  asa_resource_calculator: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :crawly,
  start_http_api: false,
  concurrent_requests_per_domain: 100,
  closespider_itemcount: 1_000_000,
  middlewares: [
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Asa Resource Calculator/1.0"]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:resources, :name]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :name},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile,
     extension: "jsonl", folder: "priv/data", include_timestamp: false}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

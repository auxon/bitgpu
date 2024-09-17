import Config

# Configure phoenix
config :phoenix, :json_library, Jason

# Configure your database
config :gpu_marketplace, GpuMarketplace.Repo,
  database: "gpu_marketplace_#{config_env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# Configures the endpoint
config :gpu_marketplace, GpuMarketplaceWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: GpuMarketplaceWeb.ErrorHTML, json: GpuMarketplaceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GpuMarketplace.PubSub  # Make sure this line is present

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Supabase
config :supabase,
  base_url: System.get_env("SUPABASE_URL"),
  api_key: System.get_env("SUPABASE_KEY")

# Additional configuration for Supabase
config :gpu_marketplace,
  supabase_url: System.get_env("SUPABASE_URL") || "https://your-project-id.supabase.co",
  supabase_key: System.get_env("SUPABASE_KEY") || "your-supabase-api-key",
  salt: System.get_env("SALT")

# Add Swagger configuration
config :phoenix_swagger, json_library: Jason

# Add these configurations if they're not already present
config :gpu_marketplace, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: GpuMarketplaceWeb.Router,
      endpoint: GpuMarketplaceWeb.Endpoint
    ]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# ... other configurations ...

config :phoenix, :format_encoders,
  json: Jason

config :mime, :types, %{
  "application/json" => ["json"]
}

# ... rest of your configurations ...

config :gpu_marketplace,
  handcash_app_secret: System.get_env("HANDCASH_APP_SECRET")

# Add esbuild and tailwind configurations
config :esbuild,
  version: "0.17.11",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# ... (rest of the file remains the same)

config :gpu_marketplace,
  ecto_repos: [GpuMarketplace.Repo]

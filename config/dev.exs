import Config

# Configure your database
config :gpu_marketplace, GpuMarketplace.Repo,
  username: "postgres",
  password: "postgres",
  database: "gpu_marketplace_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :gpu_marketplace, GpuMarketplaceWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  secret_key_base: "ea3585ee9fe3b27f43ac149962ed2c0d88ddb4e023ee1f4f97e9d064c7222495708098535e991a508e833346ba24540e68e085c31978796ef4e87b12bd11254c"

# Configure esbuild
config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets --format=esm),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)},
    external: ["/fonts/*", "/images/*"],
    define: %{
      "process.env.NODE_ENV": "\"#{Mix.env()}\"",
      "global": "window"
    },
    alias: %{
      "crypto" => "crypto-browserify",
      "stream" => "stream-browserify",
      "buffer" => "buffer"
    }
  ]

# Configure tailwind (if you're using it)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import development secrets if the file exists
if File.exists?("config/dev.secret.exs") do
  import_config "dev.secret.exs"
end

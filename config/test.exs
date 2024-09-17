import Config

# Configure your database
config :gpu_marketplace, GpuMarketplace.Repo,
  username: "postgres",
  password: "postgres",
  database: "gpu_marketplace_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gpu_marketplace, GpuMarketplaceWeb.Endpoint,
  http: [port: 4002],
  server: false
defmodule GpuMarketplace.MixProject do
  use Mix.Project

  def project do
    [
      app: :gpu_marketplace,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:phoenix_swagger],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {GpuMarketplace.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.7"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:nx, "~> 0.5"},
      {:exla, "~> 0.5"},
      {:supabase, "~> 0.2.0"},
      {:postgrestex, "~> 0.1.0"},
      {:csv, "~> 2.4"},
      {:phoenix_swagger, "~> 0.8.3"},
      {:ex_json_schema, "~> 0.7.4"},
      {:uuid, "~> 1.1"},
      {:tesla, "~> 1.4"},
      {:bitcoinex, "~> 0.1.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:msgpax, "~> 2.3"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      "assets.deploy": ["cmd npm run deploy --prefix assets", "phx.digest"]
    ]
  end
end

defmodule GpuNode.MixProject do
  use Mix.Project

  def project do
    [
      app: :gpu_node,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {GpuNode.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:websockex, "~> 0.4.3"},
      {:nx, "~> 0.5"},
      {:exla, "~> 0.5"},
      {:erlport, "~> 0.10"}
    ]
  end
end

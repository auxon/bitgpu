defmodule GpuNode.Application do
  use Application
  require Logger  # Add this line to import Logger

  def start(_type, _args) do
    # Set EXLA as the default backend for Nx
    Nx.global_default_backend(EXLA.Backend)

    # Initialize Python
    :python.start()

    gpu_id = System.get_env("GPU_ID") || "default_gpu_id"
    Logger.info("Starting GPU Node with ID: #{gpu_id}")

    children = [
      {GpuNode, []},
      {GpuNode.TaskQueue, []},
      {GpuNode.MarketplaceClient, gpu_id}
    ]

    opts = [strategy: :one_for_one, name: GpuNode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      gpu_node: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "230.1.1.1",
          multicast_ttl: 1
        ]
      ]
    ]
  end
end

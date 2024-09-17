defmodule GpuNode.Application do
  use Application

  def start(_type, _args) do
    gpu_id = Application.get_env(:gpu_node, :gpu_id, "sample_gpu_id")

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

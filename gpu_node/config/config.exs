import Config

config :gpu_node,
  marketplace_node: :"marketplace@127.0.0.1"

config :libcluster,
  topologies: [
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

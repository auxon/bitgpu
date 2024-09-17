defmodule GpuMarketplace.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GpuMarketplace.Repo,

      # Start the Telemetry supervisor
      GpuMarketplaceWeb.Telemetry,

      # Start the PubSub system
      {Phoenix.PubSub, name: GpuMarketplace.PubSub},

      # Start the Endpoint (http/https)
      GpuMarketplaceWeb.Endpoint,

      # Start the GpuManager GenServer
      GpuMarketplace.GpuManager
    ]

    opts = [strategy: :one_for_one, name: GpuMarketplace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # ... existing code ...
end

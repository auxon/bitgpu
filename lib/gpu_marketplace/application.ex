defmodule GpuMarketplace.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      GpuMarketplace.Repo,
      GpuMarketplaceWeb.Telemetry,
      {Phoenix.PubSub, name: GpuMarketplace.PubSub},
      GpuMarketplaceWeb.Endpoint,
      {GpuMarketplace.P2PManager, []},
      {GpuMarketplace.GpuManager, []}  # Add this line
    ]

    opts = [strategy: :one_for_one, name: GpuMarketplace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GpuMarketplaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

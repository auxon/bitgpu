defmodule GpuMarketplace.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GpuMarketplace.Repo,
      {Phoenix.PubSub, name: GpuMarketplace.PubSub},
      GpuMarketplaceWeb.Endpoint,
      GpuMarketplace.GpuManager  # Add this line
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

defmodule GpuMarketplaceWeb.GpuChannel do
  use GpuMarketplaceWeb, :channel

  def join("gpu:lobby", _payload, socket) do
    {:ok, socket}
  end

  # Add any other channel-specific functions here
end

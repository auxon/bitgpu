defmodule GpuMarketplaceWeb.UserSocket do
  use Phoenix.Socket

  channel "gpu:*", GpuMarketplaceWeb.GpuChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end

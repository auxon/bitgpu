defmodule GpuMarketplaceWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "gpu:*", GpuMarketplaceWeb.GpuChannel

  # Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end

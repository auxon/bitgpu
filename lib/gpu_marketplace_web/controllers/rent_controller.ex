defmodule GpuMarketplaceWeb.RentController do
  use GpuMarketplaceWeb, :controller

  alias GpuMarketplace.GPUs

  def index(conn, _params) do
    gpus = GPUs.list_available_gpus()
    render(conn, :index, gpus: gpus)
  end
end

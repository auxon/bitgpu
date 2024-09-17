defmodule GpuMarketplaceWeb.RentController do
  use GpuMarketplaceWeb, :controller
  require Logger

  def index(conn, _params) do
    case GpuMarketplace.GpuManager.list_available_gpus() do
      {:ok, gpus} ->
        render(conn, :index, gpus: gpus)
      {:error, reason} ->
        Logger.error("Failed to fetch GPUs: #{inspect(reason)}")
        conn
        |> put_flash(:error, "Unable to fetch GPUs at this time.")
        |> redirect(to: ~p"/")
    end
  end
end

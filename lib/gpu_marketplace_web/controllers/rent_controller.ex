defmodule GpuMarketplaceWeb.RentController do
  use GpuMarketplaceWeb, :controller
  require Logger
  alias GpuMarketplace.GpuManager
  alias GpuMarketplace.Payment

  def index(conn, _params) do
    case GpuManager.list_available_gpus() do
      {:ok, gpus} ->
        render(conn, :index, gpus: gpus)
      {:error, reason} ->
        Logger.error("Failed to fetch GPUs: #{inspect(reason)}")
        conn
        |> put_flash(:error, "Unable to fetch GPUs at this time.")
        |> redirect(to: ~p"/")
    end
  end

  def rent(conn, %{"id" => gpu_id, "duration" => duration}) do
    duration = String.to_integer(duration)
    case GpuManager.rent_gpu(gpu_id, duration) do
      {:ok, rental} ->
        # Process payment
        case Payment.process_payment(conn.assigns.current_user.id, rental.gpu.id, rental.total_cost) do
          {:ok, transaction} ->
            conn
            |> put_flash(:info, "GPU rented successfully. Transaction ID: #{transaction.id}")
            |> redirect(to: ~p"/rent")
          {:error, reason} ->
            conn
            |> put_flash(:error, "Payment failed: #{reason}")
            |> redirect(to: ~p"/rent")
        end
      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to rent GPU: #{reason}")
        |> redirect(to: ~p"/rent")
    end
  end
end

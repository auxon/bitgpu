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
        |> put_flash(:error, "Unable to fetch GPUs: #{reason}")
        |> redirect(to: ~p"/")
    end
  end

  def rent(conn, %{"id" => gpu_id, "duration" => duration}) do
    user_id = get_session(conn, :user_id) # Assuming you have user authentication

    case validate_and_parse_duration(duration) do
      {:ok, parsed_duration} ->
        case GpuManager.rent_gpu(gpu_id, parsed_duration) do
          {:ok, rental} ->
            # Process payment
            case Payment.process_payment(user_id, rental.gpu.id, rental.total_cost) do
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
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/rent")
    end
  end

  defp validate_and_parse_duration(duration) when is_binary(duration) do
    case Integer.parse(duration) do
      {value, ""} when value > 0 ->
        {:ok, value}
      _ ->
        {:error, "Invalid duration. Please enter a positive integer."}
    end
  end
  defp validate_and_parse_duration(_), do: {:error, "Duration is required."}
end

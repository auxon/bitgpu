defmodule GpuMarketplaceWeb.GpuController do
  use GpuMarketplaceWeb, :controller
  use PhoenixSwagger

  alias GpuMarketplace.GpuManager
  alias GpuMarketplace.HandcashClient
  alias GpuMarketplace.GPUs

  swagger_path :list do
    get "/api/gpus"
    summary "List available GPUs"
    description "Returns a list of all available GPUs for rent"
    response 200, "Success", Schema.array(:GPU)
  end

  def list(conn, _params) do
    gpus = GpuManager.list_available_gpus()
    render(conn, "index.json", gpus: gpus)
  end

  def index(conn, _params) do
    gpus = GpuManager.list_available_gpus()
    render(conn, :index, gpus: gpus)
  end

  def new(conn, _params) do
    render(conn, :new)
  end

  def rent_form(conn, %{"id" => id}) do
    case GpuMarketplace.GPUs.get_gpu(id) do
      nil ->
        conn
        |> put_flash(:error, "GPU not found")
        |> redirect(to: ~p"/gpus")
      gpu ->
        render(conn, :rent_form, gpu: gpu)
    end
  end

  swagger_path :add do
    post "/api/gpus"
    summary "Add a new GPU"
    description "Adds a new GPU to the marketplace"
    parameters do
      gpu :body, Schema.ref(:GPUParams), "The GPU details", required: true
    end
    response 201, "Created", Schema.ref(:GPU)
    response 400, "Bad Request"
  end

  def add(conn, %{"gpu" => gpu_params}) do
    gpu_id = UUID.uuid4()
    case GpuManager.add_gpu(gpu_id, gpu_params) do
      :ok ->
        conn
        |> put_status(:created)
        |> render("show.json", gpu: Map.put(gpu_params, :id, gpu_id))
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  swagger_path :rent do
    post "/api/gpus/{id}/rent"
    summary "Rent a GPU"
    description "Rents a GPU for a specified duration"
    parameters do
      id :path, :string, "GPU ID", required: true
      duration :query, :integer, "Rental duration in minutes", required: true
    end
    response 200, "Success", Schema.ref(:RentalResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end

  def rent(conn, %{"id" => gpu_id, "duration" => duration, "transactionId" => transaction_id}) do
    case GpuManager.allocate_gpu(gpu_id) do
      {:ok, gpu} ->
        case verify_handcash_transaction(transaction_id) do
          {:ok, _transaction_details} ->
            conn
            |> put_status(:ok)
            |> render("rental.json", %{gpu: gpu, duration: duration, transaction_id: transaction_id})
          {:error, reason} ->
            GpuManager.release_gpu(gpu_id)
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Transaction verification failed: #{reason}"})
        end
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "GPU not found"})
      {:error, :not_available} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "GPU is not available for rent"})
    end
  end

  defp verify_handcash_transaction(transaction_id) do
    app_secret = Application.get_env(:gpu_marketplace, :handcash_app_secret)
    case HandcashClient.verify_transaction(transaction_id, app_secret) do
      {:ok, %{status: 200, body: body}} ->
        # Here you would implement logic to verify the transaction details
        # For now, we'll just assume it's valid if we get a 200 response
        {:ok, body}
      {:ok, %{status: status}} ->
        {:error, "Unexpected status code: #{status}"}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def swagger_definitions do
    %{
      GPU: swagger_schema do
        title "GPU"
        description "A GPU available for rent"
        properties do
          id :string, "Unique identifier", required: true
          model :string, "GPU model", required: true
          memory :integer, "GPU memory in GB", required: true
          status :string, "Current status of the GPU", required: true
        end
      end,
      GPUParams: swagger_schema do
        title "GPU Parameters"
        description "Parameters for adding a new GPU"
        properties do
          model :string, "GPU model", required: true
          memory :integer, "GPU memory in GB", required: true
        end
      end,
      RentalResponse: swagger_schema do
        title "Rental Response"
        description "Response for a successful GPU rental"
        properties do
          gpu_id :string, "ID of the rented GPU", required: true
          duration :integer, "Rental duration in minutes", required: true
          transaction_id :string, "ID of the payment transaction", required: true
        end
      end
    }
  end
end

defmodule GpuMarketplaceWeb.GpuController do
  use GpuMarketplaceWeb, :controller
  use PhoenixSwagger

  alias GpuMarketplace.GPUs
  alias GpuMarketplace.GPUs.GPU
  alias GpuMarketplace.GpuManager

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
    changeset = GPUs.change_gpu(%GPU{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"gpu" => gpu_params}) do
    case GPUs.create_gpu(gpu_params) do
      {:ok, gpu} ->
        conn
        |> put_flash(:info, "GPU created successfully.")
        |> redirect(to: ~p"/gpus/#{gpu}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
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

  def rent(conn, %{"id" => gpu_id, "duration" => duration}) do
    # Convert duration to integer, defaulting to 0 if it's an empty string
    duration = case Integer.parse(duration) do
      {value, _} -> value
      :error -> 0
    end

    case GpuManager.allocate_gpu(gpu_id) do
      {:ok, gpu} ->
        # For now, we'll skip the payment verification and just simulate a successful rental
        conn
        |> put_flash(:info, "GPU #{gpu.model} rented successfully for #{duration} hours.")
        |> redirect(to: ~p"/rent")
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "GPU not found")
        |> redirect(to: ~p"/rent")
      {:error, :not_available} ->
        conn
        |> put_flash(:error, "GPU is not available for rent")
        |> redirect(to: ~p"/rent")
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

  def show(conn, %{"id" => id}) do
    gpu = GPUs.get_gpu!(id)
    render(conn, :show, gpu: gpu)
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

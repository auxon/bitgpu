defmodule GpuMarketplaceWeb.GpuController do
  use GpuMarketplaceWeb, :controller
  use PhoenixSwagger
  require Logger

  alias GpuMarketplace.Gpus
  alias GpuMarketplace.Gpus.Gpu
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

  def new(conn, _params) do
    changeset = Gpus.change_gpu(%Gpu{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"gpu" => gpu_params}) do
    # Add default values for missing fields
    gpu_params = gpu_params
      |> Map.put_new("name", gpu_params["model"])
      |> Map.put_new("memory", 0)
      |> Map.put_new("status", "available")
      |> Map.put_new("description", "")
      |> Map.put("connection_info", %{
        "ip_address" => get_client_ip(conn),
        "port" => 8080  # You might want to make this configurable
      })

    case Gpus.create_gpu(gpu_params) do
      {:ok, gpu} ->
        conn
        |> put_flash(:info, "GPU created successfully.")
        |> redirect(to: ~p"/gpus/#{gpu}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "gpu" => gpu_params}) do
    gpu = Gpus.get_gpu!(id)

    case Gpus.update_gpu(gpu, gpu_params) do
      {:ok, gpu} ->
        conn
        |> put_flash(:info, "GPU updated successfully.")
        |> redirect(to: ~p"/gpus/#{gpu}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, gpu: gpu, changeset: changeset)
    end
  end

  def rent_form(conn, %{"id" => id}) do
    case Gpus.get_gpu(id) do
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
    # Convert duration to integer
    duration = String.to_integer(duration)

    case GpuManager.rent_gpu(gpu_id, duration) do
      {:ok, rental} ->
        conn
        |> put_status(:ok)
        |> render("rental.json", rental: rental)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    gpu = Gpus.get_gpu!(id)
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

  defp get_client_ip(conn) do
    conn.remote_ip
    |> :inet.ntoa()
    |> to_string()
  end
end

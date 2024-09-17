defmodule GpuMarketplace.GpuManager do
  use GenServer
  require Logger

  alias GpuMarketplace.Gpus

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_gpu(gpu_id, specs) do
    GenServer.call(__MODULE__, {:add_gpu, gpu_id, specs})
  end

  def get_gpu(gpu_id) do
    GenServer.call(__MODULE__, {:get_gpu, gpu_id})
  end

  def list_available_gpus do
    GenServer.call(__MODULE__, :list_available_gpus)
  end

  def allocate_gpu(gpu_id) do
    case Gpus.get_gpu(gpu_id) do
      nil ->
        {:error, :not_found}
      gpu ->
        # Your allocation logic here
        {:ok, gpu}
    end
  end

  def release_gpu(gpu_id) do
    GenServer.call(__MODULE__, {:release_gpu, gpu_id})
  end

  def rent_gpu(gpu_id, duration) do
    # Implement the rental logic here
    # This should include:
    # 1. Checking if the GPU is available
    # 2. Processing the payment
    # 3. Updating the GPU status
    # 4. Creating a rental record
    # 5. Any necessary broadcasting

    # For now, let's return a mock successful response
    {:ok, %{gpu_id: gpu_id, duration: duration, transaction_id: "mock_transaction_id"}}
  end

  # Server Callbacks

  @impl true
  def init(_) do
    case Gpus.list_available_gpus() do
      {:ok, gpus} ->
        Logger.info("GpuManager initializing with GPUs: #{inspect(gpus)}")
        {:ok, %{gpus: gpus}}
      {:error, reason} ->
        Logger.error("Failed to initialize GpuManager: #{inspect(reason)}")
        {:ok, %{gpus: []}}
    end
  end

  @impl true
  def handle_call({:add_gpu, gpu_id, specs}, _from, state) do
    new_gpus = Map.put(state.gpus, gpu_id, Map.put(specs, :status, :available))
    {:reply, :ok, %{state | gpus: new_gpus}}
  end

  # Add connection details
  def handle_call({:add_gpu, gpu_id, specs, connection_info}, _from, state) do
    new_gpus = Map.put(state.gpus, gpu_id, %{specs | status: :available, connection: connection_info})
    {:reply, :ok, %{state | gpus: new_gpus}}
  end

  @impl true
  def handle_call({:get_gpu, gpu_id}, _from, state) do
    {:reply, Map.get(state.gpus, gpu_id), state}
  end

  @impl true
  def handle_call(:list_available_gpus, _from, %{gpus: gpus} = state) do
    Logger.info("Handling :list_available_gpus call. Current state: #{inspect(state)}")
    available = Enum.filter(gpus, fn gpu -> gpu.status == :available end)
    {:reply, {:ok, available}, state}  # Wrap the result in {:ok, ...}
  end

  @impl true
  def handle_call({:allocate_gpu, gpu_id}, _from, state) do
    case Gpus.get_gpu(gpu_id) do
      nil ->
        {:reply, {:error, :not_found}, state}
      gpu ->
        {:reply, {:ok, gpu}, state}
    end
  end

  @impl true
  def handle_call({:release_gpu, gpu_id}, _from, state) do
    case Enum.find(state.gpus, fn gpu -> gpu.id == gpu_id end) do
      %{status: "rented"} = gpu ->
        updated_gpu = %{gpu | status: "available"}
        new_gpus = Enum.map(state.gpus, fn g -> if g.id == gpu_id, do: updated_gpu, else: g end)
        {:reply, :ok, %{state | gpus: new_gpus}}

      _ ->
        {:reply, {:error, :invalid_status}, state}
    end
  end
end

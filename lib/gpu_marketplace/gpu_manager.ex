defmodule GpuMarketplace.GpuManager do
  use GenServer

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
    case GpuMarketplace.GPUs.get_gpu(gpu_id) do
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

  # Server Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:add_gpu, gpu_id, specs}, _from, state) do
    new_gpus = Map.put(state.gpus, gpu_id, Map.put(specs, :status, :available))
    {:reply, :ok, %{state | gpus: new_gpus}}
  end

  @impl true
  def handle_call({:get_gpu, gpu_id}, _from, state) do
    {:reply, Map.get(state.gpus, gpu_id), state}
  end

  @impl true
  def handle_call(:list_available_gpus, _from, state) do
    available = Enum.filter(state.gpus, fn {_id, gpu} -> gpu.status == :available end)
                 |> Enum.map(fn {id, gpu} -> Map.put(gpu, :id, id) end)
    {:reply, available, state}
  end

  @impl true
  def handle_call({:allocate_gpu, gpu_id}, _from, state) do
    # Implement your GPU allocation logic here
    # For now, let's just return a mock response
    case GpuMarketplace.GPUs.get_gpu(gpu_id) do
      nil ->
        {:reply, {:error, :not_found}, state}
      gpu ->
        {:reply, {:ok, gpu}, state}
    end
  end

  @impl true
  def handle_call({:release_gpu, gpu_id}, _from, state) do
    case Map.get(state.gpus, gpu_id) do
      %{status: :allocated} ->
        updated_gpu = Map.put(state.gpus[gpu_id], :status, :available)
        new_gpus = Map.put(state.gpus, gpu_id, updated_gpu)
        {:reply, :ok, %{state | gpus: new_gpus}}

      _ ->
        {:reply, {:error, :invalid_status}, state}
    end
  end
end

defmodule GpuMarketplace.P2PManager do
  use GenServer
  require Logger  # Add this line to import Logger
  alias GpuMarketplace.MLTasks
  alias GpuMarketplaceWeb.GpuChannel

  def start_link(_) do
    Logger.info("Starting P2PManager")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    Logger.info("P2PManager initialized")
    {:ok, %{connections: %{}}}
  end

  def submit_task(gpu_id, task) do
    Logger.info("P2PManager submitting task: #{inspect(task)} to GPU: #{gpu_id}")
    GenServer.cast(__MODULE__, {:submit_task, gpu_id, task})
  end

  def update_task_result(task_id, result) do
    GenServer.cast(__MODULE__, {:update_task_result, task_id, result})
  end

  def handle_cast({:submit_task, gpu_id, task}, state) do
    Logger.info("P2PManager handling submit_task for GPU: #{gpu_id}")
    case find_available_gpu() do
      {:ok, _node} ->
        Logger.info("P2PManager sending task to GPU: #{gpu_id}, task ID: #{task.id}")
        result = GpuChannel.send_task_to_gpu(gpu_id, task)
        Logger.info("Result of sending task: #{inspect(result)}")
      {:error, reason} ->
        Logger.error("P2PManager failed to find available GPU: #{reason}")
        MLTasks.update_task(task, %{status: "failed", error: "No GPU available"})
    end
    {:noreply, state}
  end

  def handle_cast({:update_task_result, task_id, result}, state) do
    task = MLTasks.get_task!(task_id)
    MLTasks.update_task(task, %{status: "completed", result: result})
    {:noreply, state}
  end

  def handle_info({:task_completed, task}, state) do
    MLTasks.update_task(task, %{status: "completed", result: "Mock result"})
    {:noreply, state}
  end

  defp find_available_gpu do
    # For now, always return success
    {:ok, :mock_gpu_node}
  end
end

defmodule GpuMarketplace.P2PManager do
  use GenServer
  alias GpuMarketplace.MLTasks
  alias GpuMarketplaceWeb.GpuChannel

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{connections: %{}}}
  end

  def submit_task(gpu_id, task) do
    GenServer.cast(__MODULE__, {:submit_task, gpu_id, task})
  end

  def handle_cast({:submit_task, gpu_id, task}, state) do
    case find_available_gpu(state) do
      {:ok, _node} ->
        GpuChannel.send_task_to_gpu(gpu_id, task)
      {:error, _reason} ->
        MLTasks.update_task(task, %{status: "failed", error: "No GPU available"})
    end
    {:noreply, state}
  end

  defp find_available_gpu(state) do
    # Implement logic to find an available GPU node
    # This could involve checking the state of connected nodes
    # For now, we'll just return a mock node
    {:ok, :mock_gpu_node}
  end

  defp send_task_to_node(node, task) do
    # In a real implementation, this would use actual P2P communication
    # For now, we'll just simulate it
    Process.send_after(self(), {:task_completed, task}, 5000)
  end

  def handle_info({:task_completed, task}, state) do
    MLTasks.update_task(task, %{status: "completed", result: "Mock result"})
    {:noreply, state}
  end

  def update_task_result(task_id, result) do
    GenServer.cast(__MODULE__, {:update_task_result, task_id, result})
  end

  def handle_cast({:update_task_result, task_id, result}, state) do
    task = MLTasks.get_task!(task_id)
    MLTasks.update_task(task, %{status: "completed", result: result})
    {:noreply, state}
  end
end

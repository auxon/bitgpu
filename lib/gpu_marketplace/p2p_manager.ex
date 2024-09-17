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

  def distribute_ml_task(code) do
    # Logic to distribute ML task to available GPU nodes
    # This is a placeholder implementation
    case find_available_gpu_node() do
      {:ok, node} ->
        result = Node.call(node, GpuMarketplace.MLExecutor, :execute, [code])
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp find_available_gpu do
    # For now, always return success
    {:ok, :mock_gpu_node}
  end

  defp find_available_gpu_node do
    # Logic to find an available GPU node
    # This is a placeholder implementation
    {:ok, Node.self()}
  end

  def execute_ml_operation(gpu_id, operation, input_data) do
    Logger.info("Executing ML operation: #{operation} on GPU: #{gpu_id}")
    GenServer.call(__MODULE__, {:execute_ml_operation, gpu_id, operation, input_data})
  end

  def handle_call({:execute_ml_operation, gpu_id, operation, input_data}, _from, state) do
    case find_available_gpu() do
      {:ok, _node} ->
        case MLTasks.create_task(%{
          gpu_id: gpu_id,
          operation: operation,
          status: "pending",
          parameters: input_data
        }) do
          {:ok, task} ->
            # For now, let's return a mock result
            mock_result = mock_matrix_multiply(input_data)
            {:reply, {:ok, mock_result}, state}
          {:error, changeset} ->
            Logger.error("Failed to create task: #{inspect(changeset)}")
            {:reply, {:error, "Failed to create task"}, state}
        end
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  # Add this helper function for mock matrix multiplication
  defp mock_matrix_multiply(%{"matrix_a" => a, "matrix_b" => b}) do
    rows_a = length(a)
    cols_b = length(Enum.at(b, 0))
    cols_a = length(Enum.at(a, 0))

    for i <- 0..(rows_a - 1) do
      for j <- 0..(cols_b - 1) do
        Enum.reduce(0..(cols_a - 1), 0, fn k, acc ->
          acc + Enum.at(Enum.at(a, i), k) * Enum.at(Enum.at(b, k), j)
        end)
      end
    end
  end
end

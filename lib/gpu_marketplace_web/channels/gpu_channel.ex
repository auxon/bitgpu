defmodule GpuMarketplaceWeb.GpuChannel do
  use Phoenix.Channel
  require Logger
  alias GpuMarketplace.P2PManager
  alias GpuMarketplace.MLTasks

  def join("gpu:" <> gpu_id, _params, socket) do
    Logger.info("GPU #{gpu_id} joined the channel")
    {:ok, assign(socket, :gpu_id, gpu_id)}
  end

  def handle_in("task_result", %{"task_id" => task_id, "result" => result}, socket) do
    Logger.info("Received task result for task #{task_id}: #{inspect(result)}")
    task = MLTasks.get_task!(task_id)
    case MLTasks.update_task(task, %{status: "completed", result: result}) do
      {:ok, updated_task} ->
        Logger.info("Task #{task_id} updated successfully: #{inspect(updated_task)}")
        Phoenix.PubSub.broadcast(GpuMarketplace.PubSub, "task_updates", {:task_updated, updated_task})
        {:reply, :ok, socket}
      {:error, changeset} ->
        Logger.error("Failed to update task #{task_id}: #{inspect(changeset)}")
        {:reply, {:error, %{reason: "Failed to update task"}}, socket}
    end
  end

  def handle_in("execute_ml_operation", payload, socket) do
    case Msgpax.unpack(payload) do
      {:ok, %{"operation" => operation, "input_data" => input_data}} ->
        gpu_id = socket.assigns.gpu_id
        case P2PManager.execute_ml_operation(gpu_id, operation, input_data) do
          {:ok, result} ->
            {:reply, {:ok, Msgpax.pack!(%{result: result})}, socket}
          {:error, reason} ->
            {:reply, {:error, Msgpax.pack!(%{reason: reason})}, socket}
        end
      {:error, _reason} ->
        {:reply, {:error, Msgpax.pack!(%{reason: "Invalid MessagePack data"})}, socket}
    end
  end

  def send_task_to_gpu(gpu_id, task) do
    Logger.info("GpuChannel broadcasting task to GPU: #{gpu_id}, task: #{inspect(task)}")
    payload = Msgpax.pack!(%{task: task})
    result = GpuMarketplaceWeb.Endpoint.broadcast!("gpu:#{gpu_id}", "execute_task", payload)
    Logger.info("Broadcast result: #{inspect(result)}")
    result
  end
end

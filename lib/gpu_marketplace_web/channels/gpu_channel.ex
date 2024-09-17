defmodule GpuMarketplaceWeb.GpuChannel do
  use Phoenix.Channel
  alias GpuMarketplace.P2PManager

  def join("gpu:" <> gpu_id, _params, socket) do
    {:ok, assign(socket, :gpu_id, gpu_id)}
  end

  def handle_in("task_result", %{"task_id" => task_id, "result" => result}, socket) do
    P2PManager.update_task_result(task_id, result)
    {:noreply, socket}
  end

  # This function will be called by the P2PManager to send tasks to GPU nodes
  def send_task_to_gpu(gpu_id, task) do
    GpuMarketplaceWeb.Endpoint.broadcast!("gpu:#{gpu_id}", "execute_task", %{task: task})
  end
end

defmodule GpuMarketplaceWeb.TrainingChannel do
  use Phoenix.Channel

  def join("training:" <> gpu_id, _params, socket) do
    {:ok, assign(socket, :gpu_id, gpu_id)}
  end

  def handle_in("start_training", %{"gpu_id" => _gpu_id}, socket) do
    # You can add any additional logic here before starting the training
    {:reply, :ok, socket}
  end

  def broadcast_progress(gpu_id, loss) do
    GpuMarketplaceWeb.Endpoint.broadcast("training:#{gpu_id}", "progress", %{loss: loss})
  end
end

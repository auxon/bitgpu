defmodule GpuMarketplaceWeb.GpuView do
  use Phoenix.Component

  def render("index.json", %{gpus: gpus}) do
    %{data: Enum.map(gpus, &render("gpu.json", %{gpu: &1}))}
  end

  def render("show.json", %{gpu: gpu}) do
    %{data: render("gpu.json", %{gpu: gpu})}
  end

  def render("gpu.json", %{gpu: gpu}) do
    %{
      id: gpu.id,
      model: gpu.model,
      memory: gpu.memory,
      status: gpu.status
    }
  end

  def render("rental.json", %{gpu: gpu, duration: duration, transaction_id: transaction_id}) do
    %{
      gpu_id: gpu.id,
      duration: duration,
      transaction_id: transaction_id
    }
  end
end

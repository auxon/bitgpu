defmodule GpuMarketplace.GPUs do
  alias GpuMarketplace.Repo
  alias GpuMarketplace.GPUs.GPU

  def list_gpus do
    Repo.all(GPU)
  end

  def list_available_gpus do
    # For now, we'll just return all GPUs
    # In a real application, you might want to filter based on availability
    list_gpus()
  end

  def get_gpu(id), do: Repo.get(GPU, id)

  def get_gpu!(id), do: Repo.get!(GPU, id)

  def create_gpu(attrs \\ %{}) do
    %GPU{}
    |> GPU.changeset(attrs)
    |> Repo.insert()
  end

  def update_gpu(%GPU{} = gpu, attrs) do
    gpu
    |> GPU.changeset(attrs)
    |> Repo.update()
  end

  def delete_gpu(%GPU{} = gpu) do
    Repo.delete(gpu)
  end

  def change_gpu(%GPU{} = gpu, attrs \\ %{}) do
    GPU.changeset(gpu, attrs)
  end

  # ... other functions ...
end

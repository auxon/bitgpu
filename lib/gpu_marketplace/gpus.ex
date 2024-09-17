defmodule GpuMarketplace.GPUs do
  alias GpuMarketplace.Repo
  alias GpuMarketplace.GPUs.GPU
  import Ecto.Query
  require Logger

  def list_gpus do
    Repo.all(GPU)
  end

  def list_available_gpus do
    gpus = Repo.all(from g in GPU, where: g.status == "available")
    Logger.info("Fetched available GPUs: #{inspect(gpus)}")
    {:ok, gpus}
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

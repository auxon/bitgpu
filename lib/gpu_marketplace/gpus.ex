defmodule GpuMarketplace.Gpus do
  @moduledoc """
  The Gpus context.
  """

  import Ecto.Query, warn: false
  alias GpuMarketplace.Repo
  alias GpuMarketplace.Gpus.Gpu
  require Logger  # Add this line to require Logger

  def list_gpus do
    Repo.all(Gpu)
  end

  def list_available_gpus do
    try do
      gpus = Repo.all(from g in Gpu, where: g.status == :available)
      gpus = Enum.map(gpus, fn gpu ->
        if Map.has_key?(gpu, :memory) do
          gpu
        else
          Map.put(gpu, :memory, 0)
        end
      end)
      Logger.info("Fetched available GPUs: #{inspect(gpus)}")
      {:ok, gpus}
    rescue
      e in Ecto.QueryError ->
        Logger.error("Error fetching available GPUs: #{inspect(e)}")
        {:error, :database_error}
    end
  end

  def get_gpu(id), do: Repo.get(Gpu, id)

  def get_gpu!(id), do: Repo.get!(Gpu, id)

  @doc """
  Creates a gpu.
  """
  def create_gpu(attrs \\ %{}) do
    %Gpu{}
    |> Gpu.changeset(attrs)
    |> Repo.insert()
  end

  def update_gpu(%Gpu{} = gpu, attrs) do
    gpu
    |> Gpu.changeset(attrs)
    |> Repo.update()
  end

  def delete_gpu(%Gpu{} = gpu) do
    Repo.delete(gpu)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gpu changes.
  """
  def change_gpu(%Gpu{} = gpu, attrs \\ %{}) do
    Gpu.changeset(gpu, attrs)
  end

  # ... other functions ...
end

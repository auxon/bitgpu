defmodule GpuMarketplace.MLTasks do
  alias GpuMarketplace.Repo
  alias GpuMarketplace.MLTasks.Task

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  # ... (other CRUD functions as needed)
end

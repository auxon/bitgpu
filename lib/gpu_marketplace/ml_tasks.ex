defmodule GpuMarketplace.MLTasks do
  alias GpuMarketplace.Repo
  alias GpuMarketplace.MLTasks.Task

  def list_tasks do
    Repo.all(Task)
  end

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
    |> case do
      {:ok, updated_task} ->
        Logger.info("Task updated successfully: #{inspect(updated_task)}")
        {:ok, updated_task}
      {:error, changeset} ->
        Logger.error("Failed to update task: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end

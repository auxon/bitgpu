defmodule GpuMarketplaceWeb.MLTaskJSON do
  alias GpuMarketplace.MLTasks.Task

  def created(%{task: task}) do
    %{
      message: "Task created successfully",
      task: data(task)
    }
  end

  def show(%{task: task}) do
    %{data: data(task)}
  end

  def result(%{task: task}) do
    %{
      id: task.id,
      status: task.status,
      result: task.result
    }
  end

  def submitted(%{task: task}) do
    %{
      message: "Task submitted successfully",
      task: data(task)
    }
  end

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def error(%{error: error}) do
    %{error: error}
  end

  def pending(%{task: task}) do
    %{
      id: task.id,
      status: task.status,
      message: "Task is still processing"
    }
  end

  defp data(%Task{} = task) do
    %{
      id: task.id,
      status: task.status,
      gpu_id: task.gpu_id,
      # Add other fields as necessary
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end

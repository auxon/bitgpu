defmodule GpuNode do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    schedule_task_execution()
    {:ok, %{}}
  end

  def handle_info(:execute_next_task, state) do
    Logger.info("Checking for next task")
    case GpuNode.TaskQueue.dequeue() do
      {:ok, task} ->
        Logger.info("Executing task: #{inspect(task)}")
        {:ok, result} = GpuNode.TaskExecutor.execute_task(task)
        Logger.info("Task completed with result: #{inspect(result)}")
        GpuNode.MarketplaceClient.send_result(task.id, result)
      :empty ->
        Logger.info("No tasks in queue")
    end
    schedule_task_execution()
    {:noreply, state}
  end

  defp schedule_task_execution do
    Process.send_after(self(), :execute_next_task, 1000)
  end
end

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
    case GpuNode.TaskQueue.dequeue() do
      {:ok, task} ->
        {:ok, result} = GpuNode.TaskExecutor.execute_task(task)
        GpuNode.MarketplaceClient.send_result(task.id, result)
      :empty ->
        :ok
    end
    schedule_task_execution()
    {:noreply, state}
  end

  defp schedule_task_execution do
    Process.send_after(self(), :execute_next_task, 1000)
  end
end

defmodule GpuNode.TaskQueue do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("TaskQueue initialized")
    {:ok, %{queue: :queue.new()}}
  end

  def enqueue(task) do
    Logger.info("Enqueueing task: #{inspect(task)}")
    GenServer.cast(__MODULE__, {:enqueue, task})
  end

  def dequeue do
    Logger.info("Attempting to dequeue task")
    GenServer.call(__MODULE__, :dequeue)
  end

  def handle_cast({:enqueue, task}, %{queue: queue} = state) do
    new_queue = :queue.in(task, queue)
    Logger.info("Task enqueued. Queue size: #{:queue.len(new_queue)}")
    Logger.info("Current queue: #{inspect(new_queue)}")
    {:noreply, %{state | queue: new_queue}}
  end

  def handle_call(:dequeue, _from, %{queue: queue} = state) do
    case :queue.out(queue) do
      {{:value, task}, new_queue} ->
        Logger.info("Task dequeued: #{inspect(task)}")
        Logger.info("Remaining queue size: #{:queue.len(new_queue)}")
        {:reply, {:ok, task}, %{state | queue: new_queue}}
      {:empty, _} ->
        Logger.info("Queue is empty. Current state: #{inspect(state)}")
        {:reply, :empty, state}
    end
  end
end

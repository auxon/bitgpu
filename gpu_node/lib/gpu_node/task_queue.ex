defmodule GpuNode.TaskQueue do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{queue: :queue.new()}}
  end

  def enqueue(task) do
    GenServer.cast(__MODULE__, {:enqueue, task})
  end

  def dequeue do
    GenServer.call(__MODULE__, :dequeue)
  end

  def handle_cast({:enqueue, task}, %{queue: queue} = state) do
    {:noreply, %{state | queue: :queue.in(task, queue)}}
  end

  def handle_call(:dequeue, _from, %{queue: queue} = state) do
    case :queue.out(queue) do
      {{:value, task}, new_queue} ->
        {:reply, {:ok, task}, %{state | queue: new_queue}}
      {:empty, _queue} ->
        {:reply, :empty, state}
    end
  end
end

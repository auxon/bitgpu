defmodule GpuNode.MarketplaceClient do
  use WebSockex
  require Logger

  @marketplace_url "ws://localhost:4000/socket/websocket"

  def start_link(gpu_id) do
    state = %{gpu_id: gpu_id}
    Logger.info("Attempting to connect to marketplace WebSocket with GPU ID: #{gpu_id}")
    {:ok, pid} = WebSockex.start_link(@marketplace_url, __MODULE__, state, name: __MODULE__)
    Process.send_after(pid, :send_join, 1000)
    {:ok, pid}
  end

  def send_result(task_id, result) do
    Logger.info("Sending result for task #{task_id}: #{inspect(result)}")
    message = Jason.encode!(%{
      event: "task_result",
      payload: %{task_id: task_id, result: result}
    })
    WebSockex.send_frame(__MODULE__, {:text, message})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected to marketplace WebSocket")
    send(self(), :after_connect)
    {:ok, state}
  end

  def handle_info(:after_connect, state) do
    Logger.info("Sending join message for gpu:#{state.gpu_id}")
    join_message = Jason.encode!(%{
      event: "phx_join",
      topic: "gpu:#{state.gpu_id}",
      payload: %{},
      ref: "1"
    })
    {:reply, {:text, join_message}, state}
  end

  def handle_info(:send_join, state) do
    join_message = Jason.encode!(%{
      event: "phx_join",
      topic: "gpu:#{state.gpu_id}",
      payload: %{},
      ref: "1"
    })
    {:reply, {:text, join_message}, state}
  end

  def handle_frame({:text, msg}, state) do
    Logger.info("GPU Node received message: #{msg}")
    case Jason.decode(msg) do
      {:ok, %{"event" => "execute_task", "payload" => payload}} ->
        Logger.info("Received execute_task event with payload: #{inspect(payload)}")
        task = payload["task"]
        Logger.info("Extracted task: #{inspect(task)}")
        GpuNode.TaskQueue.enqueue(task)
        Logger.info("Task enqueued in TaskQueue")
      {:ok, %{"event" => "phx_reply", "payload" => %{"status" => "ok"}, "ref" => "1"}} ->
        Logger.info("GPU Node successfully joined gpu:#{state.gpu_id} channel")
      _ ->
        Logger.warning("GPU Node received unexpected message: #{msg}")
    end
    {:ok, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local disconnect: #{inspect(reason)}")
    {:reconnect, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end

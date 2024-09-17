defmodule GpuNode.MarketplaceClient do
  use WebSockex
  require Logger

  @marketplace_url "ws://localhost:4000/socket/websocket"

  def start_link(gpu_id) do
    state = %{gpu_id: gpu_id}
    {:ok, pid} = WebSockex.start_link(@marketplace_url, __MODULE__, state, name: __MODULE__)
    Process.send_after(pid, :send_join, 1000)
    {:ok, pid}
  end

  def send_result(task_id, result) do
    message = Jason.encode!(%{
      event: "task_result",
      payload: %{task_id: task_id, result: result}
    })
    WebSockex.send_frame(__MODULE__, {:text, message})
  end

  def handle_connect(conn, state) do
    Logger.info("Connected to marketplace")
    join_message = Jason.encode!(%{
      event: "phx_join",
      topic: "gpu:#{state.gpu_id}",
      payload: %{},
      ref: "1"
    })
    {:ok, state}
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
    case Jason.decode(msg) do
      {:ok, %{"event" => "execute_task", "payload" => payload}} ->
        task = payload["task"]
        Logger.info("Received task: #{inspect(task)}")
        GpuNode.TaskQueue.enqueue(task)
      {:ok, %{"event" => "phx_reply", "payload" => %{"status" => "ok"}, "ref" => "1"}} ->
        Logger.info("Successfully joined gpu:#{state.gpu_id} channel")
      _ ->
        Logger.warning("Received unexpected message: #{msg}")
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

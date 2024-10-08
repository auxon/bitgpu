defmodule GpuMarketplaceWeb.TaskStatusLive do
  use Phoenix.LiveView
  alias GpuMarketplace.MLTasks
  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(GpuMarketplace.PubSub, "task_updates")
      Process.send_after(self(), :update, 1000)
    end
    tasks = MLTasks.list_tasks()
    Logger.info("Initial tasks: #{inspect(tasks)}")
    {:ok, assign(socket, tasks: tasks, selected_task: nil)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    tasks = MLTasks.list_tasks()
    Logger.info("Updated tasks: #{inspect(tasks)}")
    {:noreply, assign(socket, tasks: tasks)}
  end

  def handle_info({:task_updated, updated_task}, socket) do
    Logger.info("Received task update: #{inspect(updated_task)}")
    updated_tasks = Enum.map(socket.assigns.tasks, fn task ->
      if task.id == updated_task.id, do: updated_task, else: task
    end)
    {:noreply, assign(socket, tasks: updated_tasks)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2>Task Status</h2>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Status</th>
            <th>GPU ID</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <%= for task <- @tasks do %>
            <tr>
              <td><%= task.id %></td>
              <td><%= task.status %></td>
              <td><%= task.gpu_id %></td>
              <td>
                <%= if task.status == "completed" do %>
                  <button phx-click="view_result" phx-value-id={task.id} id={"view-result-#{task.id}"}>
                    View Result
                  </button>
                <% else %>
                  Waiting...
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <%= if @selected_task do %>
        <div>
          <h3>Task Result for Task ID: <%= @selected_task.id %></h3>
          <pre><%= Jason.encode!(@selected_task.result, pretty: true) %></pre>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("view_result", %{"id" => id}, socket) do
    Logger.info("View Result button clicked for task ID: #{id}")
    task_id = String.to_integer(id)
    task = Enum.find(socket.assigns.tasks, &(&1.id == task_id))

    case task do
      nil ->
        Logger.error("Task not found: #{task_id}")
        {:noreply, put_flash(socket, :error, "Task not found")}
      task ->
        Logger.info("Viewing result for task #{id}: #{inspect(task)}")
        {:noreply, assign(socket, selected_task: task)}
    end
  end

  def handle_event(event, params, socket) do
    Logger.warning("Unhandled event: #{event}, params: #{inspect(params)}")
    {:noreply, socket}
  end
end

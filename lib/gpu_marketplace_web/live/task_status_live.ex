defmodule GpuMarketplaceWeb.TaskStatusLive do
  use Phoenix.LiveView
  alias GpuMarketplace.MLTasks
  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)
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
                  <button phx-click="view_result" phx-value-id={task.id}>View Result</button>
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
          <h3>Task Result</h3>
          <pre><%= Jason.encode!(@selected_task.result, pretty: true) %></pre>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("view_result", %{"id" => id}, socket) do
    task = MLTasks.get_task!(id)
    Logger.info("Viewing result for task #{id}: #{inspect(task)}")
    {:noreply, assign(socket, selected_task: task)}
  end
end

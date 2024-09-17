defmodule GpuMarketplaceWeb.TaskStatusLive do
  use Phoenix.LiveView
  alias GpuMarketplace.MLTasks

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)
    {:ok, assign(socket, tasks: MLTasks.list_tasks())}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:noreply, assign(socket, tasks: MLTasks.list_tasks())}
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
            <th>Result</th>
          </tr>
        </thead>
        <tbody>
          <%= for task <- @tasks do %>
            <tr>
              <td><%= task.id %></td>
              <td><%= task.status %></td>
              <td><%= task.result %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end

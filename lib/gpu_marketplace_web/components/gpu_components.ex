defmodule GpuMarketplaceWeb.GPUComponents do
  use Phoenix.Component

  def gpu_request_form(assigns) do
    ~H"""
    <form phx-submit="request_gpu">
      <input type="hidden" name="gpu_id" value={@gpu.id} />
      <button type="submit">Request GPU</button>
    </form>
    """
  end

  def task_result(assigns) do
    ~H"""
    <div id="task-result-{@gpu_id}">
      Result: <%= @result %>
    </div>
    """
  end
end

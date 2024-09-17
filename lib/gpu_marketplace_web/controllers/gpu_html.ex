defmodule GpuMarketplaceWeb.GpuHTML do
  use GpuMarketplaceWeb, :html

  # Import CoreComponents explicitly
  import GpuMarketplaceWeb.CoreComponents

  embed_templates "gpu_html/*"

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :gpu, GpuMarketplace.GPUs.GPU, required: true
  attr :gpus, :list, required: true

  def gpu_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={@action}>
      <.error :if={@changeset.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <.input field={f[:model]} type="text" label="Model" />
      <.input field={f[:memory]} type="number" label="Memory (GB)" />
      <.input field={f[:price_per_hour]} type="number" label="Price per Hour ($)" step="0.01" />
      <:actions>
        <.button>Save GPU</.button>
      </:actions>
    </.simple_form>
    """
  end

  def show(assigns) do
    ~H"""
    <.header>
      GPU <%= @gpu.id %>
      <:subtitle>This is a GPU record from your database.</:subtitle>
      <:actions>
        <.link href={~p"/gpus/#{@gpu}/edit"}>
          <.button>Edit GPU</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Model"><%= @gpu.model %></:item>
      <:item title="Memory"><%= @gpu.memory %> GB</:item>
      <:item title="Price per Hour">$<%= @gpu.price_per_hour %></:item>
    </.list>

    <.back navigate={~p"/gpus"}>Back to GPUs</.back>
    """
  end

  def gpu_list(assigns) do
    ~H"""
    <div class="mt-8 bg-white shadow overflow-hidden sm:rounded-lg">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Model</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Memory</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price per Hour</th>
            <th scope="col" class="relative px-6 py-3">
              <span class="sr-only">Rent</span>
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for gpu <- @gpus do %>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= gpu.model %></td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= gpu.memory %> GB</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">$<%= gpu.price_per_hour %></td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <.link href={~p"/gpus/#{gpu.id}/rent"} class="text-indigo-600 hover:text-indigo-900">Rent</.link>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end

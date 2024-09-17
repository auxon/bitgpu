defmodule GpuMarketplaceWeb.CoreComponents do
  use Phoenix.Component
  # Remove the import to avoid conflicts
  # import Phoenix.HTML.Link

  # Remove the unused alias
  # alias Phoenix.LiveView.JS

  # Add any core components you need here.
  # For example:

  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:type, fn -> "button" end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:rest, fn -> %{} end)

    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def flash_group(assigns) do
    ~H"""
    <div class="fixed top-0 left-0 w-full z-50">
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash kind={:warning} title="Warning" flash={@flash} />
    </div>
    """
  end

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      class="relative isolate flex items-center gap-x-6 overflow-hidden bg-gray-50 px-6 py-2.5 sm:px-3.5 sm:before:flex-1"
    >
      <div class="flex flex-wrap items-center gap-x-4 gap-y-2">
        <p class="text-sm leading-6 text-gray-900">
          <strong class="font-semibold"><%= @title %></strong>
          <%= msg %>
        </p>
      </div>
      <div class="flex flex-1 justify-end">
        <button type="button" class="-m-3 p-3 focus-visible:outline-offset-[-4px]">
          <span class="sr-only">Dismiss</span>
          <svg class="h-5 w-5 text-gray-900" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z" />
          </svg>
        </button>
      </div>
    </div>
    """
  end

  def header(assigns) do
    ~H"""
    <header class="bg-white shadow">
      <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <h1 class="text-3xl font-bold leading-tight text-gray-900">
          <%= render_slot(@inner_block) %>
        </h1>
        <%= if assigns[:actions] do %>
          <%= render_slot(@actions) %>
        <% end %>
      </div>
    </header>
    """
  end

  def table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <%= for col <- @col do %>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                <%= col[:label] %>
              </th>
            <% end %>
            <%= if @action do %>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for row <- @rows do %>
            <tr>
              <%= for col <- @col do %>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <%= render_slot(col, row) %>
                </td>
              <% end %>
              <%= if @action do %>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <%= render_slot(@action, row) %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def simple_form(assigns) do
    assigns = assign_new(assigns, :rest, fn -> %{} end)
    ~H"""
    <.form :let={f} for={@for} action={@action} {@rest}>
      <div class="space-y-8 bg-white mt-10">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  def input(assigns) do
    assigns =
      assigns
      |> assign_new(:type, fn -> "text" end)
      |> assign_new(:errors, fn -> [] end)
      |> assign_new(:rest, fn -> %{} end)

    ~H"""
    <div phx-feedback-for={input_name(assigns)}>
      <.label for={input_id(assigns)}><%= @label %></.label>
      <input
        type={@type}
        name={input_name(assigns)}
        id={input_id(assigns)}
        value={input_value(assigns)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp input_id(%{field: %Phoenix.HTML.FormField{} = field}), do: field.id
  defp input_id(%{id: id}), do: id
  defp input_id(%{name: name}), do: name

  defp input_name(%{field: %Phoenix.HTML.FormField{} = field}), do: field.name
  defp input_name(%{name: name}), do: name

  defp input_value(%{field: %Phoenix.HTML.FormField{} = field}), do: field.value
  defp input_value(%{value: value}), do: value
  defp input_value(_), do: nil

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # Update the icon component
  attr :name, :string, required: true
  attr :class, :string, default: "h-5 w-5"
  def icon(assigns) do
    ~H"""
    <svg
      class={@class}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 20 20"
      fill="currentColor"
      aria-hidden="true"
    >
      <%= render_icon(@name) %>
    </svg>
    """
  end

  # Update the render_icon function
  defp render_icon(name) do
    case name do
      "hero-exclamation-circle-mini" ->
        {:safe, """
        <path
          fill-rule="evenodd"
          d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
          clip-rule="evenodd"
        />
        """}
      # Add more icon cases as needed
      _ ->
        {:safe, """
        <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
        """}
    end
  end

  # Add more icon paths as needed

  # Add more components as needed

  def back(assigns) do
    ~H"""
    <%= live_patch to: @navigate, class: "font-semibold text-sm text-zinc-900 hover:text-zinc-700" do %>
      <.icon name="hero-arrow-left-solid" class="w-3 h-3 mr-1" />
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end

  # Rename `link` to `app_link`
  def app_link(assigns) do
    ~H"""
    <%= Phoenix.HTML.Link.link(@inner_block, @assigns) %>
    """
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <%= for {dt, dd} <- @items do %>
          <div class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
            <dt class="w-1/4 flex-none text-zinc-500"><%= dt %></dt>
            <dd class="text-zinc-700"><%= dd %></dd>
          </div>
        <% end %>
      </dl>
    </div>
    """
  end
end

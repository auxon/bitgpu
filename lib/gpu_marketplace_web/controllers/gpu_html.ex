defmodule GpuMarketplaceWeb.GpuHTML do
  use GpuMarketplaceWeb, :html

  # Import CoreComponents explicitly
  import GpuMarketplaceWeb.CoreComponents

  embed_templates "gpu_html/*"

  @doc """
  Renders a gpu form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def gpu_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={@action}>
      <.error :if={@changeset.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <.input field={f[:name]} type="text" label="Name" />
      <.input field={f[:description]} type="text" label="Description" />
      <.input field={f[:price_per_hour]} type="number" label="Price per hour" step="0.01" />
      <.input
        field={f[:status]}
        type="select"
        label="Status"
        options={Ecto.Enum.values(GpuMarketplace.Gpus.Gpu, :status)}
      />
      <:actions>
        <.button>Save GPU</.button>
      </:actions>
    </.simple_form>
    """
  end
end

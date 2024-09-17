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

  def gpu_form(assigns)
end

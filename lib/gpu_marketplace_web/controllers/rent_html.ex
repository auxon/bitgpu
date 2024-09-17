defmodule GpuMarketplaceWeb.RentHTML do
  use GpuMarketplaceWeb, :html

  # Change this line to use alias instead of import
  alias GpuMarketplaceWeb.CoreComponents

  embed_templates "rent_html/*"

  @doc """
  Renders a list of GPUs available for rent.
  """
  attr :gpus, :list, required: true

  def gpu_list(assigns)
end

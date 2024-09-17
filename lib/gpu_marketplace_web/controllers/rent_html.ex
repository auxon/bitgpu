defmodule GpuMarketplaceWeb.RentHTML do
  use GpuMarketplaceWeb, :html

  embed_templates "rent_html/*"

  attr :gpus, :list, required: true
  def gpu_list(assigns)
end

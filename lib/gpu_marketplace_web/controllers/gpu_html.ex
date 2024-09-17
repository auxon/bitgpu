defmodule GpuMarketplaceWeb.GpuHTML do
  use GpuMarketplaceWeb, :html

  alias GpuMarketplaceWeb.CoreComponents

  embed_templates "gpu_html/*"

  @doc """
  Renders a list of GPUs.
  """
  attr :gpus, :list, required: true
  def index(assigns)

  @doc """
  Renders a form to add a new GPU.
  """
  def new(assigns)

  @doc """
  Renders a form to rent a GPU.
  """
  attr :gpu, :map, required: true
  def rent_form(assigns)
end

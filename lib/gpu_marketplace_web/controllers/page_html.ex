defmodule GpuMarketplaceWeb.PageHTML do
  use GpuMarketplaceWeb, :html

  alias GpuMarketplaceWeb.CoreComponents

  def home(assigns) do
    ~H"""
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 min-h-screen">
      <div class="container mx-auto px-4 py-16">
        <CoreComponents.header class="text-center text-white mb-12">
          <h1 class="text-4xl font-bold mb-4">Decentralized GPU Marketplace</h1>
          <p class="text-xl">Rent or provide GPUs for AI training</p>
        </CoreComponents.header>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">For Renters</h2>
            <ul class="space-y-2">
              <li>Browse available GPUs</li>
              <li>Rent a GPU for your AI training needs</li>
              <li>Upload your training data securely</li>
            </ul>
            <CoreComponents.button type="button" class="mt-4 bg-blue-500 hover:bg-blue-600 text-white">
              Browse GPUs
            </CoreComponents.button>
          </div>
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">For Providers</h2>
            <ul class="space-y-2">
              <li>List your GPU on the marketplace</li>
              <li>Set your own pricing</li>
              <li>Earn money from your idle GPU resources</li>
            </ul>
            <CoreComponents.button type="button" class="mt-4 bg-purple-500 hover:bg-purple-600 text-white">
              List Your GPU
            </CoreComponents.button>
          </div>
        </div>

        <div class="text-center">
          <CoreComponents.button type="button" class="bg-green-500 hover:bg-green-600 text-white text-lg px-8 py-3">
            Connect with HandCash
          </CoreComponents.button>
        </div>
      </div>
    </div>
    """
  end
end

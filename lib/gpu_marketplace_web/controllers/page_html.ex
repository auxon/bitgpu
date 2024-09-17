defmodule GpuMarketplaceWeb.PageHTML do
  use GpuMarketplaceWeb, :html

  alias GpuMarketplaceWeb.CoreComponents

  def home(assigns) do
    ~H"""
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 min-h-screen">
      <div class="container mx-auto px-4 py-16">
        <.header class="text-center text-white mb-12">
          Decentralized GPU Marketplace
          <:subtitle>Rent or provide GPUs for AI training</:subtitle>
        </.header>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">For Renters</h2>
            <ul class="space-y-2">
              <li>Browse available GPUs</li>
              <li>Rent a GPU for your AI training needs</li>
              <li>Upload your training data securely</li>
            </ul>
            <!-- Updated Browse GPUs button with improved styling -->
            <.link href={~p"/rent"} class="mt-4 inline-block bg-blue-600 hover:bg-blue-700 text-white text-lg px-8 py-3 rounded-lg shadow">
              Browse GPUs
            </.link>
          </div>
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">For Providers</h2>
            <ul class="space-y-2">
              <li>List your GPU on the marketplace</li>
              <li>Set your own pricing</li>
              <li>Earn money from your idle GPU resources</li>
            </ul>
            <!-- Updated List Your GPUs button with improved styling -->
            <.link href={~p"/gpus/new"} class="mt-4 inline-block bg-purple-600 hover:bg-purple-700 text-white text-lg px-8 py-3 rounded-lg shadow">
              List Your GPU
            </.link>
          </div>
        </div>

        <div class="text-center">
          <!-- Added consistent styling to Connect with HandCash button -->
          <CoreComponents.button type="button" class="bg-green-600 hover:bg-green-700 text-white text-lg px-8 py-3 rounded-lg shadow">
            Connect with HandCash
          </CoreComponents.button>
        </div>
      </div>
    </div>
    """
  end
end

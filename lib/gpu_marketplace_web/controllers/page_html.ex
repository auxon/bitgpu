defmodule GpuMarketplaceWeb.PageHTML do
  use GpuMarketplaceWeb, :html

  alias GpuMarketplaceWeb.CoreComponents

  embed_templates "page_html/*"

  def home(assigns) do
    ~H"""
    <CoreComponents.flash_group flash={@flash} />
    <div class="container mx-auto px-4 py-8">
      <CoreComponents.header>
        Welcome to the Decentralized GPU Marketplace
        <:subtitle>Rent or provide GPUs for AI training</:subtitle>
        <:actions>
          <CoreComponents.link href={~p"/rent"} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
            Browse Available GPUs <span aria-hidden="true">&rarr;</span>
          </CoreComponents.link>
        </:actions>
      </CoreComponents.header>

      <div class="mt-8 grid grid-cols-1 gap-8 md:grid-cols-2">
        <div class="bg-white shadow overflow-hidden sm:rounded-lg">
          <div class="px-4 py-5 sm:px-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">For Renters</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">Find the perfect GPU for your AI training needs</p>
          </div>
          <div class="border-t border-gray-200 px-4 py-5 sm:p-0">
            <dl class="sm:divide-y sm:divide-gray-200">
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">Browse GPUs</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  <CoreComponents.link href={~p"/rent"} class="text-indigo-600 hover:text-indigo-900">View available GPUs</CoreComponents.link>
                </dd>
              </div>
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">Rent a GPU</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Select a GPU and specify rental duration</dd>
              </div>
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">Upload Data</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Securely upload your training data</dd>
              </div>
            </dl>
          </div>
        </div>

        <div class="bg-white shadow overflow-hidden sm:rounded-lg">
          <div class="px-4 py-5 sm:px-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">For Providers</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">Offer your GPU resources to the marketplace</p>
          </div>
          <div class="border-t border-gray-200 px-4 py-5 sm:p-0">
            <dl class="sm:divide-y sm:divide-gray-200">
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">List Your GPU</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  <CoreComponents.link href={~p"/gpus/new"} class="text-indigo-600 hover:text-indigo-900">Add your GPU to the marketplace</CoreComponents.link>
                </dd>
              </div>
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">Set Pricing</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Define your hourly rate for GPU usage</dd>
              </div>
              <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt class="text-sm font-medium text-gray-500">Manage Rentals</dt>
                <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Track and manage your GPU rentals</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      <div class="mt-12 text-center">
        <h2 class="text-2xl font-semibold text-gray-900">Ready to get started?</h2>
        <div class="mt-8 flex justify-center">
          <CoreComponents.button type="button" phx-click="connect_handcash" class="mr-4">Connect with HandCash</CoreComponents.button>
          <CoreComponents.link href={~p"/rent"} class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            Browse GPUs
          </CoreComponents.link>
        </div>
      </div>
    </div>
    """
  end
end

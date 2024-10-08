defmodule GpuMarketplaceWeb.Router do
  use GpuMarketplaceWeb, :router
  use PhoenixSwagger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GpuMarketplaceWeb do
    pipe_through :browser

    get "/", PageController, :home

    # GPU routes
    get "/gpus", GpuController, :index
    get "/gpus/new", GpuController, :new
    post "/gpus", GpuController, :create
    get "/gpus/:id", GpuController, :show
    get "/gpus/:id/edit", GpuController, :edit
    put "/gpus/:id", GpuController, :update
    patch "/gpus/:id", GpuController, :update
    delete "/gpus/:id", GpuController, :delete
    get "/gpus/:id/rent", GpuController, :rent_form
    post "/gpus/:id/rent", GpuController, :rent

    # Add this new route
    get "/rent", RentController, :index

    post "/upload-training-data", TrainingDataController, :upload

    # Add this to your :browser scope
    post "/rent/:id", RentController, :rent

    live "/task-status", TaskStatusLive
  end

  # Remove this line:
  # socket "/socket", GpuMarketplaceWeb.UserSocket

  scope "/api", GpuMarketplaceWeb do
    pipe_through :api

    get "/gpus", GpuController, :list
    post "/gpus", GpuController, :add
    post "/gpus/:id/rent", GpuController, :rent
    post "/upload-training-data", TrainingDataController, :upload
    post "/train", TrainingController, :train
    get "/evaluate", TrainingController, :evaluate

    # ... (existing routes)
    resources "/ml_tasks", MLTaskController, only: [:create, :show]
    get "/ml_tasks/:id/result", MLTaskController, :view_result
    post "/ml_tasks/submit", MLTaskController, :submit

    post "/ml/execute", MLController, :execute
  end

  scope "/api/swagger" do
    pipe_through :browser

    get "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :gpu_marketplace, swagger_file: "swagger.json"
  end

  # Enable Swagger JSON endpoint
  scope "/api" do
    pipe_through :api
    get "/swagger.json", PhoenixSwagger.Plug.SwaggerUI, :swagger_json
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:gpu_marketplace, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GpuMarketplaceWeb.Telemetry
    end
  end
end

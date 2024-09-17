defmodule GpuMarketplaceWeb.PageController do
  use GpuMarketplaceWeb, :controller
  use PhoenixSwagger

  swagger_path :home do
    get "/"
    summary "Get Home Page"
    description "Returns the home page of the application"
    response 200, "Success"
  end

  def home(conn, _params) do
    render(conn, :home)
  end

  swagger_path :api_home do
    get "/api"
    summary "Get API Home"
    description "Returns a welcome message for the API"
    response 200, "Success", Schema.ref(:ApiHomeResponse)
  end

  def api_home(conn, _params) do
    json(conn, %{message: "Welcome to GPU Marketplace API"})
  end

  def swagger_definitions do
    %{
      ApiHomeResponse: swagger_schema do
        title "API Home Response"
        description "Response schema for the API home endpoint"
        properties do
          message :string, "Welcome message", required: true
        end
      end
    }
  end
end

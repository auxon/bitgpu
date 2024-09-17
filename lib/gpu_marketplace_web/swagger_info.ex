defmodule GpuMarketplaceWeb.SwaggerInfo do
  @moduledoc false

  @spec swagger_info() :: map()
  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "GPU Marketplace API",
        description: "API Documentation for GPU Marketplace",
        termsOfService: "http://swagger.io/terms/",
        contact: %{
          name: "API Support",
          url: "http://www.example.com/support",
          email: "support@example.com"
        },
        license: %{
          name: "Apache 2.0",
          url: "https://www.apache.org/licenses/LICENSE-2.0.html"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"]
    }
  end
end

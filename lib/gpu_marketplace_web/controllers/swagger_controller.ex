defmodule GpuMarketplaceWeb.SwaggerController do
  use GpuMarketplaceWeb, :controller

  def swagger(conn, _params) do
    swagger_file = "#{:code.priv_dir(:gpu_marketplace)}/static/swagger.json"
    swagger_data = File.read!(swagger_file)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, swagger_data)
  end
end

defmodule GpuMarketplaceWeb.Plugs.APIKeyAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> api_key] <- get_req_header(conn, "authorization"),
         true <- api_key == System.get_env("API_KEY") do
      conn
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: "Invalid API Key"})
        |> halt()
    end
  end
end
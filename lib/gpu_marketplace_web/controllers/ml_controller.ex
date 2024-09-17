defmodule GpuMarketplaceWeb.MLController do
  use GpuMarketplaceWeb, :controller
  alias GpuMarketplace.P2PManager
  require Logger

  def execute(conn, _params) do
    {:ok, body, conn} = read_body(conn)
    Logger.debug("Received body: #{inspect(body)}")
    case Msgpax.unpack(body) do
      {:ok, %{"operation" => operation, "input_data" => input_data}} ->
        Logger.info("Unpacked data: operation=#{operation}, input_data=#{inspect(input_data)}")
        gpu_id = "gpu_1"
        case P2PManager.execute_ml_operation(gpu_id, operation, input_data) do
          {:ok, result} ->
            Logger.info("Operation result: #{inspect(result)}")
            conn
            |> put_resp_content_type("application/msgpack")
            |> send_resp(200, Msgpax.pack!(%{result: result}))
          {:error, reason} ->
            Logger.error("Operation error: #{inspect(reason)}")
            conn
            |> put_resp_content_type("application/msgpack")
            |> send_resp(422, Msgpax.pack!(%{error: to_string(reason)}))
        end
      {:error, reason} ->
        Logger.error("Failed to unpack MessagePack data: #{inspect(reason)}")
        conn
        |> put_resp_content_type("application/msgpack")
        |> send_resp(400, Msgpax.pack!(%{error: "Invalid MessagePack data"}))
    end
  end
end

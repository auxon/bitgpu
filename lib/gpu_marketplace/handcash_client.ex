defmodule GpuMarketplace.HandcashClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.handcash.io/v1"
  plug Tesla.Middleware.JSON

  def verify_transaction(transaction_id, app_secret) do
    headers = [{"Authorization", "Bearer #{app_secret}"}]
    get("/transactions/#{transaction_id}", headers: headers)
  end
end

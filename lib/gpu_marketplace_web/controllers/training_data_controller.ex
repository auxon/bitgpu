defmodule GpuMarketplaceWeb.TrainingDataController do
  use GpuMarketplaceWeb, :controller

  def upload(conn, _params) do
    # Implement file upload logic here
    conn
    |> put_flash(:info, "Training data uploaded successfully.")
    |> redirect(to: ~p"/")
  end
end

defmodule GpuMarketplaceWeb.TrainingDataController do
  use GpuMarketplaceWeb, :controller

  def upload(conn, params) do
    # Handle the file upload here
    # You can access the uploaded file with params["upload"]["training_data"]

    # For now, let's just redirect back to the rent page with a flash message
    conn
    |> put_flash(:info, "Training data uploaded successfully")
    |> redirect(to: ~p"/rent")
  end
end

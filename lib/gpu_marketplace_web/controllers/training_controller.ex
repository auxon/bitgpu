defmodule GpuMarketplaceWeb.TrainingController do
  use GpuMarketplaceWeb, :controller
  use PhoenixSwagger
  import Nx.Defn
  alias GpuMarketplace.DataHandler

  @learning_rate 0.01
  @num_epochs 10
  @checkpoint_interval 5

  defn init_params do
    key = Nx.Random.key(42)
    {w1, key} = Nx.Random.normal(key, 0.0, 0.1, shape: {10, 20})
    {b1, key} = Nx.Random.normal(key, 0.0, 0.1, shape: {20})
    {w2, key} = Nx.Random.normal(key, 0.0, 0.1, shape: {20, 1})
    {b2, _key} = Nx.Random.normal(key, 0.0, 0.1, shape: {1})
    {w1, b1, w2, b2}
  end

  defn predict({w1, b1, w2, b2}, x) do
    x
    |> Nx.dot(w1)
    |> Nx.add(b1)
    |> Nx.sigmoid()
    |> Nx.dot(w2)
    |> Nx.add(b2)
  end

  defn loss({w1, b1, w2, b2}, x, y) do
    y_pred = predict({w1, b1, w2, b2}, x)
    Nx.mean(Nx.pow(y_pred - y, 2))
  end

  defn update({w1, b1, w2, b2}, x, y, lr) do
    {grad_w1, grad_b1, grad_w2, grad_b2} = grad({w1, b1, w2, b2}, &loss(&1, x, y))
    {
      w1 - grad_w1 * lr,
      b1 - grad_b1 * lr,
      w2 - grad_w2 * lr,
      b2 - grad_b2 * lr
    }
  end

  swagger_path :train do
    post "/api/train"
    summary "Train Model"
    description "Initiates the training process for the model on a rented GPU"
    parameters do
      gpu_id :query, :string, "ID of the rented GPU", required: true
      learning_rate :query, :number, "Learning rate for the training process", required: false
      num_epochs :query, :integer, "Number of epochs for training", required: false
    end
    response 200, "Success", Schema.ref(:TrainingResponse)
    response 400, "Bad Request"
    response 404, "GPU not found"
  end

  def train(conn, params) do
    gpu_id = Map.get(params, "gpu_id")
    learning_rate = Map.get(params, "learning_rate", @learning_rate)
    num_epochs = Map.get(params, "num_epochs", @num_epochs)

    case GpuMarketplace.GpuManager.get_gpu(gpu_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "GPU not found"})

      _gpu ->  # Change this line
        params = load_checkpoint() || init_params()

        {final_params, losses} =
          Enum.reduce(1..num_epochs, {params, []}, fn epoch, {params, losses} ->
            {batch_x, batch_y} = DataHandler.get_batch()
            new_params = update(params, batch_x, batch_y, learning_rate)
            new_loss = loss(new_params, batch_x, batch_y) |> Nx.to_number()

            if rem(epoch, @checkpoint_interval) == 0 do
              save_checkpoint(new_params)
            end

            GpuMarketplaceWeb.TrainingChannel.broadcast_progress(gpu_id, new_loss)
            {new_params, [new_loss | losses]}
          end)

        final_loss = hd(losses)
        save_checkpoint(final_params)

        GpuMarketplace.GpuManager.release_gpu(gpu_id)

        conn
        |> put_status(:ok)
        |> json(%{message: "Training completed", loss: final_loss, losses: Enum.reverse(losses)})
    end
  end

  swagger_path :evaluate do
    get "/api/evaluate"
    summary "Evaluate Model"
    description "Evaluates the trained model"
    response 200, "Success", Schema.ref(:EvaluationResults)
    response 404, "Model not found"
  end

  def evaluate(conn, _params) do
    case load_checkpoint() do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No trained model found"})

      params ->
        {batch_x, batch_y} = DataHandler.get_batch()
        eval_loss = loss(params, batch_x, batch_y) |> Nx.to_number()

        conn
        |> put_status(:ok)
        |> json(%{message: "Evaluation completed", loss: eval_loss})
    end
  end

  defp save_checkpoint(params) do
    binary = :erlang.term_to_binary(params)
    File.write!("checkpoint.bin", binary)
  end

  defp load_checkpoint do
    case File.read("checkpoint.bin") do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, _} -> nil
    end
  end

  def swagger_definitions do
    %{
      TrainingResponse: swagger_schema do
        title "Training Response"
        description "Response schema for the training process"
        properties do
          message :string, "Status message", required: true
          loss :number, "Final loss value", required: true
          losses :array, "List of loss values per epoch", items: :number, required: true
        end
      end,
      EvaluationResults: swagger_schema do
        title "Evaluation Results"
        description "Results of model evaluation"
        properties do
          message :string, "Status message", required: true
          loss :number, "Evaluation loss", required: true
        end
      end
    }
  end
end

defmodule GpuNode.TaskExecutor do
  require Logger
  import Nx.Defn

  def execute_task(task) do
    Logger.info("Starting execution of task: #{inspect(task)}")
    try do
      # Parse task parameters
      %{"parameters" => %{"input_data" => input_data, "model_type" => model_type, "execution_engine" => execution_engine}} = task

      result = case execution_engine do
        "nx" -> execute_nx_task(model_type, input_data)
        "python" -> execute_python_task(model_type, input_data)
        _ -> {:error, "Unsupported execution engine"}
      end

      case result do
        {:ok, output} ->
          Logger.info("Task completed successfully: #{inspect(output)}")
          {:ok, %{status: "completed", output: output}}
        {:error, reason} ->
          Logger.error("Task execution failed: #{reason}")
          {:error, "Task execution failed: #{reason}"}
      end
    rescue
      e ->
        Logger.error("Error executing task: #{inspect(e)}")
        {:error, "Task execution failed: #{Exception.message(e)}"}
    end
  end

  defp execute_nx_task(model_type, input_data) do
    input_tensor = Nx.tensor(input_data)

    case model_type do
      "linear_regression" ->
        {:ok, output} = linear_regression(input_tensor)
        {:ok, Nx.to_flat_list(output)}
      "logistic_regression" ->
        {:ok, output} = logistic_regression(input_tensor)
        {:ok, Nx.to_flat_list(output)}
      _ -> {:error, "Unsupported model type for Nx"}
    end
  end

  defp execute_python_task(model_type, input_data) do
    python_script = prepare_python_script(model_type, input_data)
    {:ok, pid} = :python.start()
    result = :python.call(pid, :builtins, :exec, [python_script])
    :python.stop(pid)
    {:ok, result}
  end

  defn linear_regression(input) do
    # Ensure input is 2-dimensional
    input = if Nx.rank(input) == 1, do: Nx.reshape(input, {1, Nx.axis_size(input, 0)}), else: input

    # Simple linear regression model
    weights = Nx.random_normal({1, Nx.axis_size(input, 1)}, seed: 42, backend: Nx.BinaryBackend)
    bias = Nx.random_normal({1, 1}, seed: 42, backend: Nx.BinaryBackend)

    output = Nx.dot(input, Nx.transpose(weights)) + bias
    {:ok, output}
  end

  defn logistic_regression(input) do
    # Ensure input is 2-dimensional
    input = if Nx.rank(input) == 1, do: Nx.reshape(input, {1, Nx.axis_size(input, 0)}), else: input

    # Simple logistic regression model
    weights = Nx.random_normal({1, Nx.axis_size(input, 1)}, seed: 42, backend: Nx.BinaryBackend)
    bias = Nx.random_normal({1, 1}, seed: 42, backend: Nx.BinaryBackend)

    output = Nx.sigmoid(Nx.dot(input, Nx.transpose(weights)) + bias)
    {:ok, output}
  end

  defp prepare_python_script(model_type, input_data) do
    """
    import numpy as np
    import torch
    import torch.nn as nn

    input_data = #{Jason.encode!(input_data)}
    x = torch.tensor(input_data, dtype=torch.float32)

    if "#{model_type}" == "linear_regression":
        model = nn.Linear(x.shape[1], 1)
        output = model(x)
    elif "#{model_type}" == "logistic_regression":
        model = nn.Sequential(
            nn.Linear(x.shape[1], 1),
            nn.Sigmoid()
        )
        output = model(x)
    else:
        raise ValueError("Unsupported model type for Python")

    result = output.detach().numpy().tolist()
    print(result)
    """
  end
end

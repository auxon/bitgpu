defmodule GpuMarketplaceWeb.MLTaskController do
  use GpuMarketplaceWeb, :controller
  require Logger  # Add this line to import Logger
  alias GpuMarketplace.MLTasks
  alias GpuMarketplace.P2PManager

  def create(conn, %{"task" => task_params}) do
    case MLTasks.create_task(task_params) do
      {:ok, task} ->
        Logger.info("Task created: #{inspect(task)}")
        P2PManager.submit_task(task.gpu_id, task)
        conn
        |> put_status(:created)
        |> render(:created, task: task)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    task = MLTasks.get_task!(id)
    render(conn, :show, task: task)
  end

  def result(conn, %{"id" => id}) do
    task = MLTasks.get_task!(id)
    case task.status do
      "completed" ->
        render(conn, :result, result: task.result)
      "failed" ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, error: task.error)
      _ ->
        conn
        |> put_status(:accepted)
        |> render(:pending)
    end
  end

  # New action for submitting tasks via API
  def submit(conn, %{"task" => task_params}) do
    Logger.info("Received task submission: #{inspect(task_params)}")
    case MLTasks.create_task(task_params) do
      {:ok, task} ->
        Logger.info("Task created: #{inspect(task)}")
        P2PManager.submit_task(task.gpu_id, task)
        conn
        |> put_status(:accepted)
        |> render(:submitted, task: task)
      {:error, changeset} ->
        Logger.error("Failed to create task: #{inspect(changeset)}")
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def view_result(conn, %{"id" => id}) do
    task = MLTasks.get_task!(id)
    case task.status do
      "completed" ->
        render(conn, :result, task: task)
      "failed" ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, error: task.error)
      _ ->
        conn
        |> put_status(:accepted)
        |> render(:pending, task: task)
    end
  end
end

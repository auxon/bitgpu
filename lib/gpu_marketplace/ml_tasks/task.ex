defmodule GpuMarketplace.MLTasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ml_tasks" do
    field :status, :string
    field :gpu_id, :string
    field :result, :map

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:status, :gpu_id, :result])
    |> validate_required([:status, :gpu_id])
  end
end

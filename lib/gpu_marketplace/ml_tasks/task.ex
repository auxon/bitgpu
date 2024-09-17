defmodule GpuMarketplace.MLTasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ml_tasks" do
    field :gpu_id, :string
    field :operation, :string
    field :status, :string
    field :parameters, :map
    field :result, :map

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:gpu_id, :operation, :status, :parameters, :result])
    |> validate_required([:gpu_id, :operation, :status, :parameters])
  end
end

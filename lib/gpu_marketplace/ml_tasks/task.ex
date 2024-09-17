defmodule GpuMarketplace.MLTasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :status, :gpu_id, :result, :parameters, :inserted_at, :updated_at]}
  schema "ml_tasks" do
    field :status, :string
    field :gpu_id, :string
    field :result, :map
    field :parameters, :map

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:status, :gpu_id, :result, :parameters])
    |> validate_required([:status, :gpu_id, :parameters])
  end
end

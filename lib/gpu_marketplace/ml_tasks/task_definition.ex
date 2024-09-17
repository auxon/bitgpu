defmodule GpuMarketplace.MLTasks.TaskDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_definitions" do
    field :name, :string
    field :description, :string
    field :parameters, :map
    field :python_script_template, :string

    timestamps()
  end

  def changeset(task_definition, attrs) do
    task_definition
    |> cast(attrs, [:name, :description, :parameters, :python_script_template])
    |> validate_required([:name, :python_script_template])
  end
end

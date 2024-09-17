defmodule GpuMarketplace.Repo.Migrations.CreateMlTasks do
  use Ecto.Migration

  def change do
    create table(:ml_tasks) do
      add :status, :string
      add :gpu_id, :string
      add :result, :map

      timestamps()
    end
  end
end

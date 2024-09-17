defmodule GpuMarketplace.Repo.Migrations.RecreateMlTasks do
  use Ecto.Migration

  def change do
    drop table(:ml_tasks)

    create table(:ml_tasks) do
      add :gpu_id, :string
      add :operation, :string
      add :status, :string
      add :parameters, :map
      add :result, :map

      timestamps()
    end
  end
end

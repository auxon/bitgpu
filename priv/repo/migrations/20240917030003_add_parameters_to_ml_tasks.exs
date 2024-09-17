defmodule GpuMarketplace.Repo.Migrations.AddParametersToMlTasks do
  use Ecto.Migration

  def change do
    alter table(:ml_tasks) do
      add :parameters, :map
    end
  end
end

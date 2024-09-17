defmodule GpuMarketplace.Repo.Migrations.AddMemoryToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add :memory, :integer, default: 0
    end
  end
end

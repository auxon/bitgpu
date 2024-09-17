defmodule GpuMarketplace.Repo.Migrations.AddConnectionInfoToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add :connection_info, :map
    end
  end
end

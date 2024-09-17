defmodule GpuMarketplace.Repo.Migrations.AddStatusToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add :status, :string, default: "available"
    end
  end
end

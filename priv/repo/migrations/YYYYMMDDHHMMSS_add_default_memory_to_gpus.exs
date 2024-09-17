defmodule GpuMarketplace.Repo.Migrations.AddDefaultMemoryToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add :memory, :integer, default: 0, null: false
    end

    execute "UPDATE gpus SET memory = 0 WHERE memory IS NULL"
  end
end

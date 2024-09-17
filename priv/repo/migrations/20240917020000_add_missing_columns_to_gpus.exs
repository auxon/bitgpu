defmodule GpuMarketplace.Repo.Migrations.AddMissingColumnsToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add :name, :string
      add :description, :string
      add :price_per_hour, :decimal
      add :status, :string
      # Only add the following if they don't exist
      add_if_not_exists :connection_info, :map
    end
  end
end

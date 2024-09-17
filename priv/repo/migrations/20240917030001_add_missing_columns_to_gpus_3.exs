defmodule GpuMarketplace.Repo.Migrations.AddMissingColumnsToGpus do
  use Ecto.Migration

  def change do
    alter table(:gpus) do
      add_if_not_exists :model, :string
      add_if_not_exists :memory, :integer
      add_if_not_exists :name, :string
      add_if_not_exists :description, :string
      add_if_not_exists :price_per_hour, :decimal
      add_if_not_exists :status, :string
      add_if_not_exists :connection_info, :map
    end
  end
end

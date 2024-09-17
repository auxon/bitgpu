defmodule GpuMarketplace.Repo.Migrations.CreateGpus do
  use Ecto.Migration

  def change do
    create table(:gpus) do
      add :model, :string, null: false
      add :memory, :integer, null: false
      add :price_per_hour, :decimal, null: false, precision: 10, scale: 2

      timestamps()
    end
  end
end

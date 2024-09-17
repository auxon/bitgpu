defmodule GpuMarketplace.GPUs.GPU do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gpus" do
    field :model, :string
    field :memory, :integer
    field :price_per_hour, :decimal

    timestamps()
  end

  def changeset(gpu, attrs) do
    gpu
    |> cast(attrs, [:model, :memory, :price_per_hour])
    |> validate_required([:model, :memory, :price_per_hour])
    |> validate_number(:memory, greater_than: 0)
    |> validate_number(:price_per_hour, greater_than: 0)
  end
end

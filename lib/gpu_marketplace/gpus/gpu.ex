defmodule GpuMarketplace.GPUs.GPU do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gpus" do
    field :model, :string
    field :memory, :integer
    field :price_per_hour, :decimal
    field :status, :string, default: "available"

    timestamps()
  end

  @doc false
  def changeset(gpu, attrs) do
    gpu
    |> cast(attrs, [:model, :memory, :price_per_hour, :status])
    |> validate_required([:model, :memory, :price_per_hour])
    |> validate_inclusion(:status, ["available", "rented"])
  end
end

defmodule GpuMarketplace.Gpus.Gpu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gpus" do
    field :name, :string
    field :status, Ecto.Enum, values: [:available, :rented, :maintenance], default: :available
    field :description, :string
    field :connection_info, :map
    field :price_per_hour, :decimal
    field :model, :string
    field :memory, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(gpu, attrs) do
    gpu
    |> cast(attrs, [:name, :status, :description, :connection_info, :price_per_hour, :model, :memory])
    |> validate_required([:name, :status, :price_per_hour, :model, :memory])
    |> validate_number(:memory, greater_than: 0)
    |> validate_number(:price_per_hour, greater_than: 0)
    |> validate_connection_info()
  end

  defp validate_connection_info(changeset) do
    validate_change(changeset, :connection_info, fn _, connection_info ->
      case connection_info do
        %{"ip_address" => ip, "port" => port} when is_binary(ip) and is_integer(port) ->
          []
        _ ->
          [connection_info: "must contain valid ip_address and port"]
      end
    end)
  end
end

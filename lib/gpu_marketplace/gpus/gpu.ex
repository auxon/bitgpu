defmodule GpuMarketplace.Gpus.Gpu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gpus" do
    field :name, :string
    field :description, :string
    field :price_per_hour, :decimal
    field :status, Ecto.Enum, values: [:available, :rented, :offline]
    field :connection_info, :map

    timestamps()
  end

  @doc false
  def changeset(gpu, attrs) do
    gpu
    |> cast(attrs, [:name, :description, :price_per_hour, :status, :connection_info])
    |> validate_required([:name, :description, :price_per_hour, :status])
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

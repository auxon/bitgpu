defmodule GpuMarketplace.DataHandler do
  use GenServer
  require Logger

  @batch_size 32  # Define the batch size

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    supabase_url = Application.get_env(:gpu_marketplace, :supabase_url)
    supabase_key = Application.get_env(:gpu_marketplace, :supabase_key)

    case init_supabase(supabase_url, supabase_key) do
      {:ok, client} ->
        {:ok, %{client: client, current_batch: 0}}
      {:error, reason} ->
        Logger.error("Failed to initialize Supabase client: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  defp init_supabase(url, key) do
    client = Supabase.init(url, key)
    {:ok, client}
  end

  def get_batch do
    GenServer.call(__MODULE__, :get_batch)
  end

  def upload_data(file_path) do
    GenServer.cast(__MODULE__, {:upload_data, file_path})
  end

  def handle_call(:get_batch, _from, %{client: client, current_batch: current_batch} = state) do
    response = client
      |> Postgrestex.from("training_data")
      |> Postgrestex.select(["*"])
      |> Postgrestex.range(current_batch * @batch_size, (current_batch + 1) * @batch_size - 1)
      |> Postgrestex.call()

    case response do
      {:ok, data} ->
        processed_data = Enum.map(data, fn row ->
          {Nx.tensor(row.features), Nx.tensor([row.label])}
        end)
        {:reply, processed_data, %{state | current_batch: current_batch + 1}}
      {:error, error} ->
        Logger.error("Error fetching batch: #{inspect(error)}")
        {:reply, {:error, error}, state}
    end
  end

  def handle_cast({:upload_data, file_path}, %{client: client} = state) do
    file_path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.chunk_every(100)
    |> Enum.each(fn chunk ->
      data = Enum.map(chunk, fn row ->
        %{
          features: String.split(row["features"], ",") |> Enum.map(&String.to_float/1),
          label: String.to_float(row["label"])
        }
      end)

      case Postgrestex.from(client, "training_data")
           |> Postgrestex.insert(data)
           |> Postgrestex.call() do
        {:ok, _} ->
          :ok
        {:error, error} ->
          Logger.error("Upload failed: #{inspect(error)}")
      end
    end)

    {:noreply, state}
  end
end

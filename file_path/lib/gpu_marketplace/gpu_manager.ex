def init(_) do
  {:ok, %{gpus: GpuMarketplace.GPUs.list_available_gpus()}}
end

def handle_call(:list_available_gpus, _from, %{gpus: gpus} = state) do
  {:reply, gpus, state}
end

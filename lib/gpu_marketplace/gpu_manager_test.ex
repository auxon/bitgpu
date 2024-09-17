defmodule GpuMarketplace.GpuManagerTest do
  use ExUnit.Case

  alias GpuMarketplace.GpuManager

  setup do
    {:ok, _pid} = GpuManager.start_link([])
    :ok
  end

  test "allocate and release GPU" do
    GpuManager.add_gpu("gpu_1", %{model: "NVIDIA RTX 3080", memory: 10})

    assert {:ok, %{id: "gpu_1", status: :allocated}} = GpuManager.allocate_gpu("gpu_1")
    assert {:error, :already_allocated} = GpuManager.allocate_gpu("gpu_1")

    assert :ok = GpuManager.release_gpu("gpu_1")
    assert {:ok, %{id: "gpu_1", status: :allocated}} = GpuManager.allocate_gpu("gpu_1")
  end
end

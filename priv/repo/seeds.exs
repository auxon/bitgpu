alias GpuMarketplace.Repo
alias GpuMarketplace.GPUs.GPU

# Add some sample GPUs
Repo.insert!(%GPU{model: "RTX 3080", memory: 10, price_per_hour: Decimal.new("2.5"), status: "available"})
Repo.insert!(%GPU{model: "RTX 3090", memory: 24, price_per_hour: Decimal.new("4.0"), status: "available"})

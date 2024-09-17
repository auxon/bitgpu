# GPU Sharing Implementation

## Overview

This application allows clients to share GPU resources through WebGL in the browser. The backend, built with Elixir and Phoenix, manages GPU allocations and coordinates tasks via Phoenix Channels.

## Channels

- **gpu:lobby**: Main channel for GPU allocation and task management.

## Frontend Integration

- **WebGL Canvas**: Located in `gpu_list.html.heex`, used for rendering GPU tasks.
- **WebSocket Connection**: Established in `socket.js`, handles real-time communication.

## GPU Manager

- **Module**: `GpuMarketplace.GpuManager`
- **Functions**:
  - `add_gpu/2`: Add a new GPU to the marketplace.
  - `allocate_gpu/1`: Allocate a GPU for a task.
  - `release_gpu/1`: Release an allocated GPU.

## Usage

1. Users request a GPU through the interface.
2. The frontend sends a request via the GPU Channel.
3. The backend allocates the GPU and notifies the client.
4. WebGL initializes with the allocated GPU for rendering tasks.
5. Upon task completion, the GPU is released back to the pool.

## Security

- Only authenticated users can request and use GPUs.
- GPU allocations are managed to prevent overuse and ensure fair distribution.
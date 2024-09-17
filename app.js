import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()

channel.on("gpu_allocated", payload => {
  console.log("GPU Allocated:", payload.gpu);
  // Send task to provider via P2P
  p2pNetwork.sendTask(payload.gpu.connection, { task: "train_model", params: {...} });
});

channel.on("task_update", payload => {
  console.log("Task Update:", payload.status);
  // Update UI with progress
  updateProgress(payload.status);
});

channel.on("task_complete", payload => {
  console.log("Task Complete:", payload.result);
  // Display results to user
  displayResult(payload.result);
});
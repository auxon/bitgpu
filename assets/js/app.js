import './shims.js';

import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { HandCashConnect } from "./handcash-connect-browser.js"
import { createLibp2p } from 'libp2p'
import { webSockets } from '@libp2p/websockets'
import { noise } from '@libp2p/noise'

// Update the socket path to match the one defined in endpoint.ex
let socket = new Socket("/socket", { params: { token: window.userToken } })
socket.connect()

let channel = socket.channel("gpu:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined GPU channel successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("gpu_allocated", payload => {
  console.log("GPU Allocated:", payload.gpu)
  // Initialize or update WebGL with the allocated GPU
  const gl = initWebGL("webgl-canvas")
  if (gl) {
    // Perform WebGL tasks using the allocated GPU
  }
})

channel.on("allocation_error", payload => {
  console.error("GPU Allocation Error:", payload.reason)
})

export default socket

const appId = 'YOUR_APP_ID';
const appSecret = 'YOUR_APP_SECRET';

const handCashConnect = new HandCashConnect({
    appId: appId,
    appSecret: appSecret
});

// Function to handle login
export const loginWithHandcash = async () => {
    const authUrl = handcash.getLoginUrl()
    window.location.href = authUrl
}
  
// Function to handle logout
export const logoutHandcash = () => {
    handcash.revokeAuth()
}

let account;

const connectButton = document.getElementById('connectButton');
const rentalForm = document.getElementById('rentalForm');
const durationInput = document.getElementById('duration');
const rentButton = document.getElementById('rentButton');
const statusDiv = document.getElementById('status');

connectButton.addEventListener('click', async () => {
    const redirectionUrl = handCashConnect.getRedirectionUrl();
    window.location.href = redirectionUrl;
});

rentButton.addEventListener('click', rentGPU);

// Check if we're returning from HandCash authorization
const urlParams = new URLSearchParams(window.location.search);
const authToken = urlParams.get('authToken');

if (authToken) {
    connectWithHandCash(authToken);
}

async function connectWithHandCash(authToken) {
    try {
        account = handCashConnect.getAccountFromAuthToken(authToken);
        const { publicProfile } = await account.profile.getCurrentProfile();
        statusDiv.textContent = `Connected as ${publicProfile.handle}`;
        connectButton.style.display = 'none';
        rentalForm.style.display = 'block';
    } catch (error) {
        statusDiv.textContent = 'Failed to connect: ' + error.message;
    }
}

const API_KEY = 'YOUR_API_KEY'; // Replace with the actual API key from the server
const SERVER_URL = 'http://localhost:4000'; // Updated to port 4000
const WS_URL = 'ws://localhost:4000/socket/websocket'; // Updated WebSocket URL

let ws;

async function rentGPU() {
    const duration = parseInt(durationInput.value);
    const price = duration * 0.1; // $0.10 per minute

    try {
        const paymentParameters = {
            description: `GPU Rental for ${duration} minutes`,
            payments: [
                { destination: 'YOUR_HANDCASH_HANDLE', currencyCode: 'USD', sendAmount: price }
            ]
        };

        const paymentResult = await account.wallet.pay(paymentParameters);
        statusDiv.textContent = `Payment successful! TransactionID: ${paymentResult.transactionId}`;
        
        initWebSocket();
        
        const startTime = Date.now();
        const endTime = startTime + duration * 60 * 1000;

        while (Date.now() < endTime) {
            try {
                const response = await fetch(`${SERVER_URL}/train`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-API-Key': API_KEY
                    }
                });
                
                if (!response.ok) {
                    if (response.status === 404) {
                        statusDiv.textContent += '\nNo more training data available.';
                        break;
                    }
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                
                const result = await response.json();
                statusDiv.textContent += `\n${result.message}`;
            } catch (error) {
                console.error('Error during training:', error);
                statusDiv.textContent += `\nError during training: ${error.message}`;
            }
        }

        // Evaluate the model after training
        const evalResponse = await fetch(`${SERVER_URL}/evaluate`, {
            method: 'GET',
            headers: {
                'X-API-Key': API_KEY
            }
        });
        
        if (evalResponse.ok) {
            const evalResult = await evalResponse.json();
            statusDiv.textContent += `\n${evalResult.message}`;
        }

        statusDiv.textContent += '\nAI training completed!';
        ws.close();
    } catch (error) {
        statusDiv.textContent = 'Operation failed: ' + error.message;
    }
}

function initWebSocket() {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
        console.log('WebSocket connection established');
    };

    ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.type === 'progress') {
            updateProgress(data.payload);
        }
    };

    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
    };

    ws.onclose = () => {
        console.log('WebSocket connection closed');
    };
}

function updateProgress(progress) {
    statusDiv.textContent += `\nTraining loss: ${progress.loss.toFixed(4)}`;
}

async function uploadTrainingData(file) {
    const formData = new FormData();
    formData.append('file', file);

    try {
        const response = await fetch(`${SERVER_URL}/upload-training-data`, {
            method: 'POST',
            headers: {
                'X-API-Key': API_KEY
            },
            body: formData
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        statusDiv.textContent += `\n${result.message}`;
    } catch (error) {
        console.error('Error uploading training data:', error);
        statusDiv.textContent += `\nError uploading training data: ${error.message}`;
    }
}

class P2PNetwork {
    constructor() {
        this.node = null;
    }

    async init() {
        this.node = await createLibp2p({
            addresses: {
                listen: ['/ip4/0.0.0.0/tcp/0/ws']
            },
            transports: [webSockets()],
            connectionEncryption: [noise()]
        });

        await this.node.start();
        console.log('P2P node started');
    }

    async broadcastGPUAvailability(gpuInfo) {
        // Implement broadcasting logic
        const message = JSON.stringify(gpuInfo);
        await this.node.pubsub.publish('gpu-marketplace', new TextEncoder().encode(message));
    }

    async findAvailableGPU(duration) {
        // Implement GPU discovery logic
        return new Promise((resolve) => {
            this.node.pubsub.subscribe('gpu-marketplace');
            this.node.pubsub.on('gpu-marketplace', (msg) => {
                const gpuInfo = JSON.parse(new TextDecoder().decode(msg.data));
                // Check if GPU meets requirements
                if (gpuInfo.duration >= duration) {
                    resolve(gpuInfo);
                }
            });
        });
    }
}

const p2pNetwork = new P2PNetwork();

// Wrap the initialization in an async function
async function initializeP2P() {
    try {
        await p2pNetwork.init();
        console.log('P2P network initialized');
    } catch (error) {
        console.error('Failed to initialize P2P network:', error);
    }
}

// Call the initialization function
initializeP2P();

// ... rest of your code ...

// WebGL Canvas
export function initWebGL(canvasId) {
    const canvas = document.getElementById(canvasId);
    const gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
    if (!gl) {
      console.error("Unable to initialize WebGL.");
      return null;
    }
    return gl;
}

// Initialize LiveSocket for LiveView (if you're using it)
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => {
  // Show progress bar or spinner
})

window.addEventListener("phx:page-loading-stop", info => {
  // Hide progress bar or spinner
})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// ... rest of your existing code ...
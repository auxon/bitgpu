const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');
const bodyParser = require('body-parser');
const crypto = require('crypto');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const port = 3000;

app.use(cors());
app.use(bodyParser.json());

let trainingData = [];
let aggregatedResults = [];
const clients = new Set();

// Generate some dummy training data (simplified for this example)
for (let i = 0; i < 100; i++) {
    trainingData.push({
        id: i,
        matrixA: Array.from({length: 32 * 32}, () => Math.random()),
        matrixB: Array.from({length: 32 * 32}, () => Math.random())
    });
}

// Simple token-based authentication
const API_KEY = crypto.randomBytes(32).toString('hex');
console.log('API Key:', API_KEY);

function authenticateRequest(req, res, next) {
    const apiKey = req.headers['x-api-key'];
    if (apiKey && apiKey === API_KEY) {
        next();
    } else {
        res.status(401).json({ error: 'Unauthorized' });
    }
}

app.use(authenticateRequest);

app.get('/training-data', (req, res) => {
    const dataItem = trainingData.shift();
    if (dataItem) {
        res.json(dataItem);
    } else {
        res.status(404).json({ message: 'No more training data available' });
    }
});

app.post('/results', (req, res) => {
    const { id, result } = req.body;
    if (!id || !result || !Array.isArray(result)) {
        return res.status(400).json({ error: 'Invalid data format' });
    }
    aggregatedResults.push({ id, result });
    console.log(`Received result for training data ${id}`);
    res.json({ message: 'Result received' });
});

app.get('/aggregated-results', (req, res) => {
    res.json(aggregatedResults);
});

wss.on('connection', (ws) => {
    clients.add(ws);
    console.log('New WebSocket connection');

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            if (data.type === 'result') {
                aggregatedResults.push(data.payload);
                broadcastProgress();
            }
        } catch (error) {
            console.error('Error processing WebSocket message:', error);
        }
    });

    ws.on('close', () => {
        clients.delete(ws);
        console.log('WebSocket connection closed');
    });
});

function broadcastProgress() {
    const progress = (aggregatedResults.length / 100) * 100;
    const message = JSON.stringify({ type: 'progress', payload: progress });
    clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });
}

server.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
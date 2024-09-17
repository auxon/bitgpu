import os
import uvicorn
from fastapi import FastAPI, WebSocket, HTTPException, Depends, Header, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import ray
import numpy as np
import lancedb
import pyarrow as pa
import io
import pandas as pd
from typing import List
import torch
import torch.nn as nn
import torch.optim as optim

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple API key authentication
API_KEY = os.urandom(32).hex()
print(f"API Key: {API_KEY}")

# Initialize Ray
ray.init()

# Initialize LanceDB
db = lancedb.connect("./lancedb")
data_table = db.create_table("training_data", schema=pa.schema([
    pa.field("id", pa.int64()),
    pa.field("features", pa.list_(pa.float32())),
    pa.field("labels", pa.float32())
]))

model_table = db.create_table("model_params", schema=pa.schema([
    pa.field("layer", pa.string()),
    pa.field("params", pa.list_(pa.float32()))
]))

# WebSocket clients
clients = set()

# Define the neural network
class SimpleNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(SimpleNN, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, output_size)
    
    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.fc2(x)
        return x

# Initialize the model
input_size = 10  # Adjust based on your data
hidden_size = 20
output_size = 1
model = SimpleNN(input_size, hidden_size, output_size)
optimizer = optim.Adam(model.parameters())
criterion = nn.MSELoss()

# Helper functions
def verify_api_key(x_api_key: str = Header(...)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    return x_api_key

@ray.remote
def train_model(features, labels):
    features = torch.FloatTensor(features)
    labels = torch.FloatTensor(labels)
    
    optimizer.zero_grad()
    outputs = model(features)
    loss = criterion(outputs, labels)
    loss.backward()
    optimizer.step()
    
    return loss.item()

# Routes
@app.post("/upload-training-data")
async def upload_training_data(file: UploadFile = File(...), api_key: str = Depends(verify_api_key)):
    contents = await file.read()
    df = pd.read_csv(io.StringIO(contents.decode('utf-8')))
    
    data = []
    for _, row in df.iterrows():
        data.append({
            "id": row['id'],
            "features": row['features'].strip('[]').split(','),
            "labels": row['labels']
        })
    
    data_table.add(data)
    return {"message": f"Uploaded {len(data)} training data items"}

@app.post("/train")
async def train(api_key: str = Depends(verify_api_key)):
    data = data_table.search().limit(32).to_pandas()  # Get a batch of 32 samples
    if data.empty:
        raise HTTPException(status_code=404, detail="No more training data available")
    
    features = np.array(data['features'].tolist())
    labels = np.array(data['labels'].tolist())
    
    loss = await train_model.remote(features, labels)
    
    # Update model parameters in LanceDB
    for name, param in model.named_parameters():
        model_table.add([{"layer": name, "params": param.data.numpy().flatten().tolist()}])
    
    await broadcast_progress(loss)
    return {"message": f"Training completed. Loss: {loss}"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    clients.add(websocket)
    try:
        while True:
            await websocket.receive_text()
    finally:
        clients.remove(websocket)

async def broadcast_progress(loss):
    message = {"type": "progress", "payload": {"loss": loss}}
    for client in clients:
        await client.send_json(message)

@app.get("/evaluate")
async def evaluate(api_key: str = Depends(verify_api_key)):
    data = data_table.search().limit(100).to_pandas()  # Get 100 samples for evaluation
    if data.empty:
        raise HTTPException(status_code=404, detail="No evaluation data available")
    
    features = torch.FloatTensor(np.array(data['features'].tolist()))
    labels = torch.FloatTensor(np.array(data['labels'].tolist()))
    
    with torch.no_grad():
        outputs = model(features)
        loss = criterion(outputs, labels)
    
    return {"message": f"Evaluation completed. Loss: {loss.item()}"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=3000)
import os, io, json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch, boto3
from serve.model_loader import load_latest_model
app = FastAPI()
model = load_latest_model()

class Item(BaseModel):
    pixels: list[float]  # flattened 28*28 array (values 0-1)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(item: Item):
    try:
        x = torch.tensor(item.pixels, dtype=torch.float32).reshape(1, 1, 28, 28)
        logits = model(x)
        pred = int(torch.argmax(logits, dim=1))
        return {"prediction": pred}
    except Exception as e:
        raise HTTPException(400, str(e))

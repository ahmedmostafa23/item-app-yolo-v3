from fastapi import FastAPI
from pydantic import BaseModel

items = []

app = FastAPI()

class Item(BaseModel):
    item_name: str

@app.get("/api/v1/health")
def health_check():
    return {"result": "healthy"}

@app.get("/api/v1/item")
def get_items():
    return {"result": items}

@app.post("/api/v1/items")
def add_item(item: Item):
    global items
    items.append(item.item_name)
    return {"result": item.item_name}


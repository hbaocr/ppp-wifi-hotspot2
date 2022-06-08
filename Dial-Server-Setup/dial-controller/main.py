from fastapi import FastAPI
import os

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id):
    return {"item_id": item_id}


@app.get("/dial")
async def read_item():
    return {os.path.abspath(os.getcwd())}
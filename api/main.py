from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/hello")
async def hello():
    return {"message": "Hello World"}

# Artice Model
from pydantic import BaseModel
from typing import List

class Article(BaseModel):
    id: int
    title: str
    body: str
    url: str

@app.get("/articles")
async def articles() -> List[Article]:
    articles = [Article(id=1, title="Article 1", body="Content 1", url=""), Article(id=2, title="Article 2", body="Content 2", url="")]
    return articles

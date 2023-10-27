from fastapi import FastAPI, File, UploadFile, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
import boto3
from db import get_db, Base
from pydantic import BaseModel
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, Boolean
import uuid
import requests
import json
from dotenv import load_dotenv
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ArticleSchema(BaseModel):
    id: int
    uuid: str
    title: str
    description: str
    author: str
    url: str
    allow_external: bool


class ArticleModel(Base):
    __tablename__ = "articles"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    uuid = Column(String(36), unique=True, nullable=False)
    title = Column(String(255))
    description = Column(String(255))
    author = Column(String(255))
    url = Column(String(255))
    allow_external = Column(Boolean, default=False)


@app.get("/articles")
async def list_articles(db: Session = Depends(get_db)) -> List[ArticleSchema]:
    return db.query(ArticleModel).all()


@app.post("/articles")
async def create_article(
    title: str = Form(None),
    desc: str = Form(None),
    allowExternalConnection: bool = Form(None),
    file: UploadFile = File(None),
    db: Session = Depends(get_db),
) -> ArticleSchema:
    s3_bucket = "develop"
    s3_dir = "uploaded"
    region_name = "ap-northeast-1"

    s3 = boto3.client(
        "s3",
        endpoint_url="http://minio:9000",
        aws_access_key_id="minio",
        aws_secret_access_key="minio123",
        region_name=region_name,
    )
    response = s3.put_object(
        Body=file.file, Bucket=s3_bucket, Key=f"{s3_dir}/{file.filename}"
    )

    # S3にアップロードしたオブジェクトのパス
    file_url = "https://%s.s3-%s.amazonaws.com/%s" % (
        s3_bucket,
        region_name,
        s3_dir + "/" + file.filename,
    )
    article = ArticleModel(
        uuid=str(uuid.uuid4()),
        title=title,
        description=desc,
        url=file_url,
        allow_external=allowExternalConnection,
    )
    db.add(article)
    db.commit()
    db.refresh(article)
    return article

@app.get("/articles/{article_id}")
async def get_article(article_id: str, db: Session = Depends(get_db)) -> ArticleSchema:
    return db.query(ArticleModel).filter(ArticleModel.uuid == article_id).first()

class LoginResponse(BaseModel):
    token: str

@app.post("/login")
async def login(email: str = Form(None), password: str = Form(None)) -> LoginResponse:
    load_dotenv()
    login_url = os.getenv("LOGIN_URL")
    headers = {"Content-Type": "application/json"}
    data = {"email": email, "password": password, "app_key": os.getenv("APP_KEY")}
    r = requests.post(login_url, headers=headers, data=json.dumps(data))
    print(r.url)
    data = r.json()
    print(data)
    return LoginResponse(token=data["token"])

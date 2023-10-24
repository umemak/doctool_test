from fastapi import FastAPI, File, UploadFile, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
import boto3
from db import get_db, Base
from pydantic import BaseModel
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, Boolean
import uuid

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
    url: str
    allow_external: bool


class ArticleModel(Base):
    __tablename__ = "articles"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    uuid = Column(String(36), unique=True, nullable=False)
    title = Column(String(255))
    description = Column(String(255))
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

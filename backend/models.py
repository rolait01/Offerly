from typing import List
from pydantic import BaseModel

class Product(BaseModel):
    id: int
    name: str
    description: str
    price: str
    store: str
    categories: List[str]

class ScoredProduct(BaseModel):
    id: int
    name: str
    description: str
    price: str
    store: str
    score: float

class Market(BaseModel):
    name: str
    address: str
    angebote_url: str
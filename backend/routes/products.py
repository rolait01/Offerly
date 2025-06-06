from typing import List
from fastapi import APIRouter, HTTPException, Query
import state
from models import Product, ScoredProduct

router = APIRouter()

@router.get("/search", response_model=List[ScoredProduct])
def search(productName: str = Query(..., min_length=2)):
    results = state.matcher.search(productName)
    return [
        ScoredProduct(
            id=p.id,
            name=p.name,
            description=p.description,
            price=p.price,
            store=p.store,
            score=round(score, 4)
        )
        for p, score in results
    ]


@router.get("/AIsearch", response_model=List[ScoredProduct])
def search(productName: str = Query(..., min_length=2)):
    results = state.matcher.AIsearch(productName)
    return [
        ScoredProduct(
            id=p.id,
            name=p.name,
            description=p.description,
            price=p.price,
            store=p.store,
            score=round(score, 4)
        )
        for p, score in results
    ]


@router.get("/product/{product_id}", response_model=Product)
def get_product_by_id(product_id: int):
    print(f"Search by ID: ${product_id}")
    # Find product by ID
    for prod in state.products:
        if prod.id == product_id:
            return prod
    # If not found, raise 404
    raise HTTPException(status_code=404, detail="Product not found")
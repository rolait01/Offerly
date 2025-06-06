from typing import List
from fastapi import APIRouter, HTTPException, Query
from scraper.edeka_marketsearch_scraper import scrape_edeka_markets
import state
from models import Product, ScoredProduct

router = APIRouter()

@router.get("/markets/edeka/{postal_code}")
def get_product_by_id(postal_code: int):
    print(f"Search by ID: ${postal_code}")
    return scrape_edeka_markets(postal_code)
    raise HTTPException(status_code=404, detail="Markets not found")
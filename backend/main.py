import asyncio
from datetime import datetime, timedelta
import sys
from startup import load_data, load_products_from_file
import state
from routes.root import router as root_router
from routes.products import router as product_router
from routes.markets import router as markets_router
from scraper.kaufland_html_scraper import scrape_kaufland_products
from scraper.edeka_html_scraper import scrape_edeka_products
from scraper.rewe_html_scraper import scrape_rewe_products
from scraper.html_saver import save_html
from fastapi import FastAPI, HTTPException, Query
from typing import List
from models import Product, ScoredProduct
from ai_matcher import AIMatcher
from pathlib import Path
import json


if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())

app = FastAPI(title="AI Product Search API")

async def daily_load_data_task():
    while True:
        now = datetime.now()
        # Nächste Mitternacht berechnen
        next_run = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
        wait_seconds = (next_run - now).total_seconds()
        print(f"[DEBUG] Waiting {wait_seconds} seconds until next load_data run at {next_run}")
        await asyncio.sleep(wait_seconds)

        print("[DEBUG] Running load_data() now")
        await load_data()


@app.on_event("startup")
def on_startup():
    # This line is used once at startup to load all categories.
    # await load_data()

    # Starte Hintergrund-Task für tägliche Ausführung von load_data
    asyncio.create_task(daily_load_data_task())

    # Use this code if the json already exists
    load_products_from_file("all_products.json")
    #save_html("https://www.edeka.de/eh/s%C3%BCdwest/gebauer%C2%B4s-ecenter-raiffeisenstra%C3%9Fe-23/angebote.jsp", "edeka_angebote")


app.include_router(root_router)
app.include_router(product_router)
app.include_router(markets_router)

print("[DEBUG] main.py loaded")


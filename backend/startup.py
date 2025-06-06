# Beide Produktlisten laden
import asyncio
import json
import os
from pathlib import Path
from typing import List
from ai_matcher import AIMatcher, fetch_categories_for_product
from models import Product
import state
from scraper.edeka_html_scraper import scrape_edeka_products
from scraper.kaufland_html_scraper import scrape_kaufland_products
from scraper.rewe_html_scraper import scrape_rewe_products

async def load_data():
    rewe_products = scrape_rewe_products()
    edeka_products = scrape_edeka_products()
    kaufland_products = scrape_kaufland_products()
    
    # Kombinieren aller Produkte
    state.products = rewe_products + edeka_products + kaufland_products
    print(f"[DEBUG] Gesamtanzahl aller Produkte: {len(state.products)}")

    # Duplikate entfernen
    unique_product_tuples = { (p.name, p.description, p.price, p.store) for p in state.products }
    deduped_products = [Product(id=0, name=name, description=desc, price=price, store=store, categories=[]) 
                        for (name, desc, price, store) in unique_product_tuples]

    print(f"[DEBUG] Gesamtanzahl nach Entfernen von Duplikaten: {len(deduped_products)}")

    # Kategorien parallel abrufen
    coros = [fetch_categories_for_product(p) for p in deduped_products]
    categories_list = await asyncio.gather(*coros)

    # Produkte final zusammensetzen: ID + Kategorien
    state.products = []
    for idx, (product, cats) in enumerate(zip(deduped_products, categories_list), start=1):
        product.id = idx
        product.categories = cats
        state.products.append(product)

    writeProductsToJson()
    state.matcher = AIMatcher(state.products)


def writeProductsToJson():
    # JSON-Dateipfad
    json_path = Path("all_products.json")
    # Produkte in JSON-Datei schreiben (überschreiben)
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(
            [product.model_dump() for product in state.products],
            f,
            ensure_ascii=False,
            indent=2
        )
        print(f"[DEBUG] Produkte in {json_path} geschrieben.")


def load_products_from_file(filename: str) -> List[Product]:
    base_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(base_dir, filename)
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
        state.products = [Product(**item) for item in data]
        state.matcher = AIMatcher(state.products)
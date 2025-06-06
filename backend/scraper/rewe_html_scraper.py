from bs4 import BeautifulSoup
from scraper.price_formatter import extract_price
from models import Product
from typing import List
from pathlib import Path
import os
import re

def scrape_rewe_products() -> List[Product]:
    # Get the directory of the current script file
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Build an absolute path to the HTML file
    html_path = os.path.join(script_dir, "htmls", "rewe_offers.html")
    print(f"---------------------------------------------------------")
    print(f"[DEBUG] Lade HTML-Datei von: {html_path}")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    soup = BeautifulSoup(html, "html.parser")

    articles = soup.select("article.cor-offer-renderer-tile")
    print(f"[DEBUG] Gefundene Artikel (Produkte): {len(articles)}")

    products = []
    for i, article in enumerate(articles, start=1):
        info_block = article.select_one("div.cor-offer-information")

        # Name
        name_tag = info_block.select_one("a.cor-offer-information__title-link") if info_block else None
        name = name_tag["data-offer-title"].strip() if name_tag and "data-offer-title" in name_tag.attrs else "Unbekannt"

        # Description (concatenate all span texts)
        desc_tags = info_block.select("span.cor-offer-information__additional") if info_block else []
        raw_description  = " ".join(tag.get_text(strip=True) for tag in desc_tags)
        # Remove extra whitespace, newlines, tabs etc.
        description = re.sub(r"\s+", " ", raw_description).strip()

        # Preis (now from the full article, not from parent)
        price_tag = article.select_one("div.cor-offer-price__tag-price")
        raw_price = price_tag.get_text(strip=True) if price_tag else ""
        price = extract_price(raw_price)

        product = Product(
            id=0,
            name=name,
            description=description,
            price=price,
            store="Rewe",
            categories=[]
        )

        print(f"[DEBUG] Produkt {i}: {name} | {description} | {price}")
        products.append(product)

    print(f"[DEBUG] Gesamtanzahl geladener Produkte: {len(products)}")
    return products
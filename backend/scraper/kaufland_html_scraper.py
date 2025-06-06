from bs4 import BeautifulSoup
from scraper.price_formatter import extract_price
from models import Product
from typing import List
from pathlib import Path
import os
import re


def scrape_kaufland_products() -> List[Product]:
    # Get the directory of the current script file
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Build an absolute path to the HTML file
    html_path = os.path.join(script_dir, "htmls", "kaufland_offers.html")
    print(f"---------------------------------------------------------")
    print(f"[DEBUG] Lade HTML-Datei von: {html_path}")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    soup = BeautifulSoup(html, "html.parser")

    articles = soup.select("a.k-product-tile")
    print(f"[DEBUG] Gefundene Artikel (Produkte): {len(articles)}")

    products = []
    for i, article in enumerate(articles, start=1):
        # Name (title + subtitle)
        title_tag = article.select_one("div.k-product-tile__title")
        subtitle_tag = article.select_one("div.k-product-tile__subtitle")
        name = " ".join(filter(None, [
            title_tag.get_text(strip=True) if title_tag else "",
            subtitle_tag.get_text(strip=True) if subtitle_tag else ""
        ])) or "Unbekannt"

        # Description (unit price)
        desc_tag = article.select_one("div.k-product-tile__unit-price")
        description = desc_tag.get_text(strip=True) if desc_tag else ""

        # Price
        price_tag = article.select_one("div.k-price-tag__price")
        raw_price = price_tag.get_text(strip=True) if price_tag else ""
        price = extract_price(raw_price)

        product = Product(
            id=0,
            name=name,
            description=description,
            price=price,
            store="Kaufland",
            categories=[]
        )

        print(f"[DEBUG] Produkt {i}: {name} | {description} | {price}")
        products.append(product)

    print(f"[DEBUG] Gesamtanzahl geladener Produkte: {len(products)}")
    return products
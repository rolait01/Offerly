from bs4 import BeautifulSoup
from scraper.price_formatter import extract_price
from models import Product
from typing import List
import os
import re

def scrape_edeka_products() -> List[Product]:
    # Get the directory of the current script file
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Build an absolute path to the HTML file
    html_path = os.path.join(script_dir, "htmls", "edeka_offers.html")
    print(f"---------------------------------------------------------")
    print(f"[DEBUG] Lade HTML-Datei von: {html_path}")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    soup = BeautifulSoup(html, "html.parser")

    product_divs = soup.select("div.css-1uiiw0z")
    print(f"[DEBUG] Gefundene Artikel (Produkte): {len(product_divs)}")

    products = []
    for i, div in enumerate(product_divs, start=1):
        # Produktname: zuerst css-i72elb, dann css-163h5df
        name_tag = div.select_one("span.css-i72elb") or div.select_one("span.css-163h5df") or div.select_one("span.css-1290i4n") or div.select_one("span.css-1y8gzrn")
        name = name_tag.get_text(strip=True) if name_tag else "Unbekannt"

        # Beschreibung
        desc_tag = div.select_one("p.css-1skykc0")
        description = desc_tag.get_text(strip=True) if desc_tag else ""

        # Preis
        price_tag = div.select_one("span.css-111vupd")
        raw_price = price_tag.get_text(strip=True) if price_tag else ""
        price = extract_price(raw_price)

        product = Product(
            id=0,
            name=name,
            description=description,
            price=price,
            store="Edeka",
            categories=[]
        )

        print(f"[DEBUG] Produkt {i}: {name} | {description} | {price}")
        products.append(product)

    print(f"[DEBUG] Gesamtanzahl geladener Produkte: {len(products)}")
    return products
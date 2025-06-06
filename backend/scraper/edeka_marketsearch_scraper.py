from datetime import datetime
from bs4 import BeautifulSoup
from scraper.html_saver import save_html
from scraper.price_formatter import extract_price
from models import Market, Product
from typing import List
import os
import re

def scrape_edeka_markets(postalCode: str) -> List[Market]:
    save_html(f"https://www.edeka.de/marktsuche.jsp#/?searchstring={postalCode}", "edeka_markets")
    # Get the directory of the current script file
    script_dir = os.path.dirname(os.path.abspath(__file__))

    date_str = datetime.now().strftime("%d-%m-%Y")
    html_file = os.path.join(script_dir, "htmls", f"edeka_markets_{date_str}.html")
    print(f"---------------------------------------------------------")
    print(f"[DEBUG] Lade HTML-Datei von: {html_file}")
    with open(html_file, "r", encoding="utf-8") as f:
        html = f.read()

    soup = BeautifulSoup(html, "html.parser")

    store_lis = soup.select("li.o-store-search-results-listing__item")
    print(f"[DEBUG] Gefundene Stores: {len(store_lis)}")

    stores = []
    for i in soup.select("li.o-store-search-results-listing__item"):
        # Storename
        name_tag = i.select_one('span.a-core-headline')
        name = name_tag.get_text(strip=True) if name_tag else None
        print(f"[DEBUG] Name: {name}")
        # Link to offer page
        offers_link_tag = i.select_one('a[href*="angebote.jsp"]')
        offers_link = offers_link_tag['href'] if offers_link_tag else None
        print(f"[DEBUG] Link: {offers_link}")
        # Adresse
        address_tag = i.select_one('span.o-store-search-results-listing__copy-item')
        address = address_tag.get_text(strip=True) if address_tag else None
        print(f"[DEBUG] Address: {address}")

        if name and offers_link:
            market = Market(
                name=name,
                address=address,
                angebote_url=offers_link
            )
            stores.append(market)

        print(f"[DEBUG] Store {i}: {name} | {offers_link}")

    print(f"[DEBUG] Gesamtanzahl geladener Märkte: {len(stores)}")
    return stores[:5]
from datetime import datetime
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import time

def save_html(url: str, output_file: str):
    # Chrome-Einstellungen
    options = Options()
    options.add_argument("--start-maximized")  # Fenster maximieren
    # options.add_argument("--headless")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    date_str = datetime.now().strftime("%d-%m-%Y")
    chrome_driver_path = os.path.join(script_dir, "chromedriver.exe")
    html_file = os.path.join(script_dir, "htmls", f"{output_file}_{date_str}.html")
    service = Service(chrome_driver_path) 

    # Starte den Browser
    driver = webdriver.Chrome(service=service, options=options)

    try:
        driver.get(url)

        # Gib der Seite Zeit, um sich zu laden
        time.sleep(3)

        # Optional: Klicke auf Cookie-Banner, falls vorhanden
        try:
            cookie_button = driver.find_element(By.ID, "onetrust-accept-btn-handler")
            cookie_button.click()
            time.sleep(2)
        except:
            print("Kein Cookie-Banner gefunden oder bereits akzeptiert.")

        # Gesamten HTML-Quelltext speichern
        html_content = driver.page_source
        with open(html_file, "w", encoding="utf-8") as f:
            f.write(html_content)

        print(f"HTML erfolgreich gespeichert als {html_file}")

    finally:
        driver.quit()

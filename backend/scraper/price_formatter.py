import re

def extract_price(text: str) -> str:
    # Remove all non-digit, non-dot, non-comma characters
    cleaned = re.sub(r"[^\d.,]", "", text)

    # If both dot and comma are present, assume comma is thousands sep (e.g. 1.234,56)
    if "," in cleaned and "." in cleaned:
        cleaned = cleaned.replace(".", "").replace(",", ".")
    # If only comma, treat it as decimal
    elif "," in cleaned:
        cleaned = cleaned.replace(",", ".")
    # If only dot, it's already correct

    try:
        # Convert to float and format to 2 decimal places
        return f"{float(cleaned):.2f}"
    except ValueError:
        return "0.00"
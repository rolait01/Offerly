import difflib
import json
from sentence_transformers import SentenceTransformer, util
import torch
from typing import List
from models import Product
import os
from openai import OpenAI
from dotenv import load_dotenv

client = OpenAI(api_key="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")

async def fetch_categories_for_product(product: Product) -> list[str]:
    prompt = (
        f"Ich gebe dir ein Produkt aus einem Supermarkt:\n"
        f"Name: {product.name}\n"
        f"Beschreibung: {product.description}\n"
        f"Bitte nenne mir drei Kategorien, die gut zu diesem Produkt passen, "
        f"getrennt durch Kommas, ohne Erklärungen."
    )
    response = client.responses.create(
        model="gpt-4.1",
        input=prompt
    )
    # Ergebnistext bereinigen und in Liste umwandeln
    output_text = response.output_text.strip()
    print(f"ERGEBNIS: {output_text}")
    categories = [c.strip() for c in output_text.split(",") if c.strip()]
    print(categories)
    return categories


def extract_attributes(query: str) -> dict:
    print(f"QUERY: {query}")
    prompt = (
        f"Analysiere folgende Einkaufssuche und extrahiere:\n"
        f"- Mögliche Produktkategorien"
        f"- Mögliche Anlässe (occasion)"
        f"- Eine Preisobergrenze, falls genannt"
        f"Antworte im JSON-Format mit den Schlüsseln: 'categories', 'occasion', 'max_price'."
        f"Stelle dabei sicher, dass categories und occasion als Liste zurück gegeben werden."
        f"Suche: {query}"
    )
    response = client.responses.create(
        model="gpt-4.1",
        input=prompt
    )
    # Ergebnistext bereinigen und in Liste umwandeln
    output_text = response.output_text.strip()
    print(f"ERGEBNIS: {output_text}")
    parsed = json.loads(output_text)
    categories = [c.strip() for c in output_text.split(",") if c.strip()]
    print(f"TESTZUGRIFF: {parsed.get("max_price")}")
    return parsed


def combined_score(product: Product, semantic_score: float, attributes: dict) -> float:
    bonus = 0.0
    if attributes["categories"]:
        if any(cat.lower() in [c.lower() for c in product.categories] for cat in attributes["categories"]):
            bonus += 0.1
    if attributes["occasion"]:
        if any(occ.lower() in [c.lower() for c in product.categories] for occ in attributes["occasion"]):
            bonus += 0.1
    return semantic_score + bonus


class AIMatcher:
    def __init__(self, products: List[Product]):
        self.products = products
        self.model = SentenceTransformer("distiluse-base-multilingual-cased-v1")
        self.embeddings = self.model.encode(
            [p.name for p in products],
            convert_to_tensor=True
        )

    def search(self, query: str, top_k: int = 10) -> List[tuple[Product, float]]:
        # Encode all expanded queries and average them into a single embedding
        query_embedding = self.model.encode(query.lower(), convert_to_tensor=True)
        # Compute cosine similarity scores
        scores = util.pytorch_cos_sim(query_embedding, self.embeddings)[0]

        results = []
        query_lower = query.lower()

        for i, score in enumerate(scores):
            product = self.products[i]
            name_lower = product.name.lower()
            categories_lower = [cat.lower() for cat in product.categories]

            boost = 0.0

            # Literal match in product name
            if query_lower in name_lower:
                boost += 0.5

            # Exact or fuzzy match in categories
            if query_lower in categories_lower:
                boost += 0.3
            else:
                close_matches = difflib.get_close_matches(query_lower, categories_lower, n=1, cutoff=0.7)
                if close_matches:
                    boost += 0.2

            final_score = float(score) + boost
            results.append((product, final_score))

         # Sort before normalization to preserve ordering
        results.sort(key=lambda x: x[1], reverse=True)

        # Min-max normalization to percentage (0–100)
        scores_only = [score for _, score in results]
        min_score = min(scores_only)
        max_score = max(scores_only)
        range_score = max_score - min_score if max_score != min_score else 1.0

        normalized_results = [
            (product, round((score - min_score) / range_score * 100, 1))
            for product, score in results[:top_k]
        ]

        return normalized_results
    


    def semantic_scores(self, query: str, products: List[Product]) -> List[tuple[Product, float]]:
        query_embedding = self.model.encode(query, convert_to_tensor=True)
        scores = []
        for product in products:
            text = f"{product.name} {product.description} {' '.join(product.categories)}"
            product_embedding = self.model.encode(text, convert_to_tensor=True)
            similarity = util.cos_sim(query_embedding, product_embedding).item()
            scores.append((product, similarity))
        return scores


    def AIsearch(self, query: str, top_k: int = 10) -> List[tuple[Product, float]]:
        attributes = extract_attributes(query)
        filtered_products = self.products  # oder hole sie aus der DB

        # Preisfilter
        if attributes.get("max_price"):
            filtered_products = [p for p in filtered_products if float(p.price) <= attributes["max_price"]]

        semantic_scores_list = self.semantic_scores(query, filtered_products)

        # Kombination von Scores
        results = []
        for product, sem_score in semantic_scores_list:
            score = combined_score(product, sem_score, attributes)
            results.append((product, score))

        # Sortieren & Top K
        results.sort(key=lambda x: x[1], reverse=True)
        return results[:top_k]
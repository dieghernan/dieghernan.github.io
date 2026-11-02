"""Validate the blog-specific JSON-LD after a complete Jekyll build."""

import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
DATA = json.loads((ROOT / "_data/structured_data.json").read_text(encoding="utf-8"))


def page(url):
    relative = url.lstrip("/")
    path = SITE / (relative + "index.html" if url.endswith("/") else relative + ".html")
    html = path.read_text(encoding="utf-8")
    blocks = [json.loads(raw) for raw in re.findall(
        r'<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>', html, re.S)]
    return html, blocks


class StructuredDataTests(unittest.TestCase):
    def test_profile_uses_the_shared_personal_identity(self):
        _, blocks = page("/about")
        profile, = [item for item in blocks if item.get("@type") == "ProfilePage"]
        person = profile["mainEntity"]
        self.assertEqual(person["@id"], "https://dieghernan.github.io/#author")
        self.assertEqual(person["url"], "https://dieghernan.github.io/")
        self.assertEqual(set(person["sameAs"]), {
            "https://github.com/dieghernan", "https://fosstodon.org/@dhernangomez",
            "https://bsky.app/profile/dieghernan.bsky.social", "https://orcid.org/0000-0001-8457-4658"})

    def test_featured_packages_follow_the_visible_cards(self):
        html, blocks = page("/projects")
        listing, = [item for item in blocks if item.get("@type") == "ItemList"]
        self.assertEqual(listing["numberOfItems"], 6)
        self.assertEqual(len(listing["itemListElement"]), 6)
        self.assertEqual(len({item["@id"] for item in listing["itemListElement"]}), 6)
        for item in listing["itemListElement"]:
            self.assertIn('id="package-' + item["name"].lower() + '"', html)
            self.assertIn(item["url"], html)
            self.assertIn(item["codeRepository"], html)
            self.assertEqual(item["programmingLanguage"], "R")
        # The theme's general collection list remains independently available.
        self.assertEqual(len([item for item in blocks if item.get("@type") == "CollectionPage"
                             and "mainEntity" in item]), 1)

    def test_project_entities_reference_the_existing_pages(self):
        self.assertEqual(len(DATA["project_pages"]), 10)
        for url, key in DATA["project_pages"].items():
            with self.subTest(url=url):
                _, blocks = page(url)
                entity, = [item for item in blocks if item.get("@id") == DATA["entities"][key]["@id"]]
                self.assertEqual(entity["subjectOf"]["@id"], "https://dieghernan.github.io" + url)
                self.assertIn(entity["subjectOf"]["@id"], {item.get("@id") for item in blocks
                                                        if item.get("@type") == "WebPage"})
                self.assertGreaterEqual(len(entity["description"]), 50)
                for field in ("datePublished", "dateModified", "version", "distribution", "license"):
                    self.assertNotIn(field, entity)

    def test_article_relations_reuse_the_published_article_identity(self):
        urls = set(DATA["article_relations"]) | set(DATA["package_articles"])
        self.assertEqual(len(urls), 8)
        for url in urls:
            with self.subTest(url=url):
                _, blocks = page(url)
                article, = [item for item in blocks if item.get("@type") == "BlogPosting"]
                entities = [item for item in blocks if "subjectOf" in item]
                self.assertEqual(len(entities), 1)
                self.assertEqual(entities[0]["subjectOf"]["@id"], article["@id"])
        _, star_blocks = page("/202301_star-map-R/")
        celestial, = [item for item in star_blocks if item.get("@type") == "Dataset"]
        self.assertEqual(celestial["@id"], "https://dieghernan.github.io/celestial_data/#collection")

    def test_gallery_gets_no_project_specific_markup(self):
        _, blocks = page("/gallery")
        self.assertEqual([item for item in blocks if item.get("@type") in {
            "ProfilePage", "Dataset", "SoftwareSourceCode", "ItemList", "ImageObject"}], [])


if __name__ == "__main__":
    unittest.main()

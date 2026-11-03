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
    def test_standard_site_documents_link_from_the_matching_page_head(self):
        documents = json.loads((ROOT / "_data/standard_site_documents.json").read_text(encoding="utf-8"))
        for url, uri in documents.items():
            with self.subTest(url=url):
                html, _ = page(url)
                head = html.split("</head>", 1)[0]
                self.assertEqual(re.findall(r'<link rel="site.standard.document" href="([^"]+)">', head), [uri])
        html, _ = page("/about")
        self.assertNotIn('rel="site.standard.document"', html)

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
            expected_doi = {
                "tidyterra": "https://doi.org/10.21105/joss.05751",
                "cffr": "https://doi.org/10.21105/joss.03900",
            }.get(item["name"], "https://doi.org/10.32614/CRAN.package." + item["name"])
            self.assertEqual(item["sameAs"], expected_doi)
            self.assertEqual(item["author"]["@id"], "https://dieghernan.github.io/#author")
            self.assertIn("https://orcid.org/0000-0001-8457-4658", item["author"]["sameAs"])
            expected_license = ("https://www.gnu.org/licenses/gpl-3.0.html"
                                if item["name"] in {"cffr", "giscoR", "mapSpain"}
                                else "https://opensource.org/licenses/MIT")
            self.assertEqual(item["license"], expected_license)
        # The theme's general collection list remains independently available.
        self.assertEqual(len([item for item in blocks if item.get("@type") == "CollectionPage"
                             and "mainEntity" in item]), 1)

    def test_project_entities_reference_the_existing_pages(self):
        self.assertEqual(len(DATA["project_pages"]), 11)
        for url, key in DATA["project_pages"].items():
            with self.subTest(url=url):
                _, blocks = page(url)
                entity, = [item for item in blocks if item.get("@id") == DATA["entities"][key]["@id"]]
                self.assertEqual(entity["subjectOf"]["@id"], "https://dieghernan.github.io" + url)
                self.assertIn(entity["subjectOf"]["@id"], {item.get("@id") for item in blocks
                                                        if item.get("@type") == "WebPage"})
                self.assertGreaterEqual(len(entity["description"]), 50)
                if entity["@type"] == "Dataset":
                    self.assertTrue(entity["creator"])
                else:
                    self.assertEqual(entity["license"], "https://opensource.org/licenses/MIT")
                for field in ("datePublished", "dateModified", "version", "distribution"):
                    self.assertNotIn(field, entity)

    def test_postal_areas_reuse_the_canonical_dataset_identity(self):
        html, blocks = page("/projects/postal-codes-spain")
        dataset, = [item for item in blocks if item.get("@type") == "Dataset"]
        self.assertEqual(dataset["@id"], "https://dieghernan.github.io/codigospostales/#dataset")
        self.assertEqual(dataset["sameAs"], "https://doi.org/10.5281/zenodo.23698418")
        self.assertEqual(dataset["license"], "https://creativecommons.org/licenses/by/4.0/")
        self.assertEqual(dataset["creator"]["sameAs"], "https://orcid.org/0000-0001-8457-4658")
        self.assertIn("not official postal boundaries", dataset["description"])
        self.assertIn("not official postal boundaries", html)

    def test_celestial_summaries_include_verified_license_and_creators(self):
        for url in ("/projects/celestial-data/", "/202301_star-map-R/"):
            with self.subTest(url=url):
                _, blocks = page(url)
                dataset, = [item for item in blocks if item.get("@type") == "Dataset"]
                self.assertEqual(dataset["license"], "https://opensource.org/licenses/BSD-3-Clause")
                self.assertEqual([item["name"] for item in dataset["creator"]],
                                 ["Olaf Frohn", "Diego Hernangómez"])
                self.assertEqual(dataset["creator"][1]["sameAs"],
                                 "https://orcid.org/0000-0001-8457-4658")
                self.assertEqual(dataset["creator"][1]["url"], "https://dieghernan.github.io/")
                self.assertEqual(dataset["identifier"], "https://doi.org/10.5281/zenodo.7561601")

    def test_upstream_software_authors_keep_their_original_identities(self):
        for url, author_id, platform in (
                ("/projects/leaflet-providersESP/", "https://dieghernan.github.io/leaflet-providersESP/#author", "Leaflet"),
                ("/projects/spain-munic-bot/", "https://dieghernan.github.io/#author", "R")):
            with self.subTest(url=url):
                _, blocks = page(url)
                software, = [item for item in blocks if item.get("@type") == "SoftwareSourceCode"]
                self.assertEqual(software["author"]["@id"], author_id)
                self.assertEqual(software["author"]["sameAs"], "https://orcid.org/0000-0001-8457-4658")
                self.assertEqual(software["runtimePlatform"], platform)

    def test_historical_covid_snapshot_keeps_its_actual_coverage(self):
        _, blocks = page("/projects/COVID19")
        dataset, = [item for item in blocks if item.get("@type") == "Dataset"]
        self.assertEqual(dataset["temporalCoverage"], "2020-02-20/2020-04-08")
        self.assertNotIn("license", dataset)

    def test_repository_only_projects_keep_verified_authorship(self):
        _, blocks = page("/projects/corona-atlas/")
        software, = [item for item in blocks if item.get("@type") == "SoftwareSourceCode"]
        self.assertEqual(software["author"]["name"], "Diego & Rodrigo")
        for url in ("/projects/7egment/", "/projects/Bzel/", "/projects/Sfera/", "/projects/TextWatchClima/"):
            with self.subTest(url=url):
                _, blocks = page(url)
                watch, = [item for item in blocks if item.get("@type") == "SoftwareSourceCode"]
                self.assertEqual(watch["author"]["name"], "dieghernan")
                self.assertEqual(watch["author"]["url"], "https://github.com/dieghernan")

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
                if entities[0]["@type"] == "Dataset":
                    self.assertTrue(entities[0]["creator"])
                else:
                    self.assertTrue(entities[0]["license"])
        _, star_blocks = page("/202301_star-map-R/")
        celestial, = [item for item in star_blocks if item.get("@type") == "Dataset"]
        self.assertEqual(celestial["@id"], "https://dieghernan.github.io/celestial_data/#collection")

    def test_gallery_gets_no_project_specific_markup(self):
        _, blocks = page("/gallery")
        self.assertEqual([item for item in blocks if item.get("@type") in {
            "ProfilePage", "Dataset", "SoftwareSourceCode", "ItemList", "ImageObject"}], [])


if __name__ == "__main__":
    unittest.main()

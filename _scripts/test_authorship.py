"""After a full build: pip install -r _scripts/requirements-microformats.txt; python -m unittest discover -s _scripts -p test_authorship.py."""

from pathlib import Path
import unittest
import xml.etree.ElementTree as ET
from urllib.parse import urlsplit

import mf2py

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
HOME = "https://dieghernan.github.io/"
GUEST_URL = "https://uselessness.science"


def parsed(path):
    relative = path.relative_to(SITE).as_posix()
    url = HOME + relative.removesuffix("index.html")
    return mf2py.parse(doc=path.read_text(encoding="utf-8"), url=url)


class AuthorshipTests(unittest.TestCase):
    def test_home_exposes_the_canonical_personal_identity(self):
        cards = [item for item in parsed(SITE / "index.html")["items"] if "h-card" in item["type"]]
        card, = cards
        self.assertEqual(card["properties"]["name"], ["Diego HH"])
        self.assertEqual(card["properties"]["uid"], [HOME])
        self.assertEqual(card["properties"]["url"][0], HOME)

    def test_articles_keep_their_own_author_identity(self):
        cases = [
            ("202610_orange-peel/index.html", "Diego HH", HOME, HOME + "assets/img/site/avatar.png"),
            ("202610_webmentions/index.html", "Diego HH", HOME, HOME + "assets/img/site/avatar.png"),
            ("202203_Corona-timelapse/index.html", "Rodrigo Hernangómez", GUEST_URL, "https://github.com/rodrihgh.png"),
        ]
        for relative, name, url, photo in cases:
            with self.subTest(article=relative):
                entry, = [item for item in parsed(SITE / relative)["items"] if "h-entry" in item["type"]]
                author, = entry["properties"]["author"]
                self.assertIn("h-card", author["type"])
                self.assertEqual(author["properties"]["name"], [name])
                self.assertEqual(author["properties"]["url"][0], url)
                self.assertEqual(author["properties"]["photo"][0]["value"], photo)

    def test_custom_atom_feeds_use_each_authors_canonical_url(self):
        ns = {"a": "http://www.w3.org/2005/Atom"}
        for filename in ("rbloggers.xml", "rweekly.xml"):
            with self.subTest(feed=filename):
                feed = ET.parse(SITE / filename).getroot()
                self.assertEqual(feed.findtext("a:author/a:name", namespaces=ns), "Diego HH")
                self.assertEqual(feed.findtext("a:author/a:uri", namespaces=ns), HOME)
                entries = feed.findall("a:entry", ns)
                self.assertGreater(len(entries), 0)
                for entry in entries:
                    name = entry.findtext("a:author/a:name", namespaces=ns)
                    expected = GUEST_URL if name == "Rodrigo Hernangómez" else HOME
                    self.assertIn(name, ("Diego HH", "Rodrigo Hernangómez"))
                    self.assertEqual(entry.findtext("a:author/a:uri", namespaces=ns), expected)

    def test_all_blog_pages_declare_feed_and_entry_authors(self):
        pages = sorted((SITE / "blog").rglob("index.html"))
        self.assertGreater(len(pages), 1)
        guest_entries = []
        seen_entries = set()
        for path in pages:
            with self.subTest(page=path.relative_to(SITE)):
                feed, = [item for item in parsed(path)["items"] if "h-feed" in item["type"]]
                feed_author, = feed["properties"]["author"]
                self.assertEqual(feed["properties"]["name"], ["Blog"])
                self.assertEqual(feed_author["properties"]["name"], ["Diego HH"])
                self.assertEqual(feed_author["properties"]["url"], [HOME])
                expected_url = HOME + path.relative_to(SITE).as_posix().removesuffix("index.html")
                self.assertEqual(feed["properties"]["url"], [expected_url])
                entries = [item for item in feed["children"] if "h-entry" in item["type"]]
                self.assertGreater(len(entries), 0)
                for entry in entries:
                    url, = entry["properties"]["url"]
                    self.assertNotIn(url, seen_entries)
                    seen_entries.add(url)
                    author, = entry["properties"]["author"]
                    properties = author["properties"]
                    if urlsplit(url).path == "/202203_Corona-timelapse/":
                        guest_entries.append(url)
                        self.assertEqual(properties["name"], ["Rodrigo Hernangómez"])
                        self.assertEqual(properties["url"], [GUEST_URL])
                        self.assertEqual(properties["uid"], [GUEST_URL])
                        self.assertEqual(properties["photo"][0]["value"], "https://github.com/rodrihgh.png")
                    else:
                        self.assertEqual(properties["name"], ["Diego HH"])
                        self.assertEqual(properties["url"], [HOME])
                        self.assertEqual(properties["uid"], [HOME])
                        self.assertEqual(properties["photo"][0]["value"], HOME + "assets/img/site/avatar.png")
        self.assertEqual(guest_entries, [HOME + "202203_Corona-timelapse/"])


if __name__ == "__main__":
    unittest.main()

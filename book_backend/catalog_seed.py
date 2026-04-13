from __future__ import annotations

import argparse
import json
from pathlib import Path

try:
    from .catalog_data import ARABIC_BOOKS, ENGLISH_BOOKS
    from .catalog_utils import (
        ensure_catalog_schema,
        replace_book_content,
        reset_catalog_tables,
    )
    from .database import get_connection
    from .import_amwaj_akma import BOOK_AUTHOR as AMWAJ_AKMA_AUTHOR
    from .import_amwaj_akma import BOOK_TITLE as AMWAJ_AKMA_TITLE
    from .import_amwaj_akma import SOURCE_BOOK_PATH as AMWAJ_AKMA_SOURCE
    from .import_amwaj_akma import convert_book as convert_amwaj_akma_book
    from .import_book import BOOK_AUTHOR as ALICE_AUTHOR
    from .import_book import BOOK_TITLE as ALICE_TITLE
    from .import_book import DEFAULT_BOOK_PATH as ALICE_SOURCE
    from .import_book import normalize_chapters
except ImportError:
    from catalog_data import ARABIC_BOOKS, ENGLISH_BOOKS
    from catalog_utils import (
        ensure_catalog_schema,
        replace_book_content,
        reset_catalog_tables,
    )
    from database import get_connection
    from import_amwaj_akma import BOOK_AUTHOR as AMWAJ_AKMA_AUTHOR
    from import_amwaj_akma import BOOK_TITLE as AMWAJ_AKMA_TITLE
    from import_amwaj_akma import SOURCE_BOOK_PATH as AMWAJ_AKMA_SOURCE
    from import_amwaj_akma import convert_book as convert_amwaj_akma_book
    from import_book import BOOK_AUTHOR as ALICE_AUTHOR
    from import_book import BOOK_TITLE as ALICE_TITLE
    from import_book import DEFAULT_BOOK_PATH as ALICE_SOURCE
    from import_book import normalize_chapters


def _load_alice_chapters(book_path: Path) -> list[dict]:
    with book_path.open("r", encoding="utf-8") as file:
        raw_book = json.load(file)
    return normalize_chapters(raw_book["chapters"])


def _load_amwaj_akma_chapters(book_path: Path) -> list[dict]:
    converted = convert_amwaj_akma_book(book_path)
    return [
        {
            "chapter_number": index,
            "title": chapter["title"],
            "content": chapter["content"],
        }
        for index, chapter in enumerate(converted["chapters"], start=1)
    ]


def _insert_catalog_books(cursor) -> dict[tuple[str, str], int]:
    mapping = {}
    catalog = [*ENGLISH_BOOKS, *ARABIC_BOOKS]

    for order, entry in enumerate(catalog, start=1):
        cursor.execute(
            """
            INSERT INTO books (
                title,
                author,
                description,
                cover_image,
                language,
                is_featured,
                sort_order
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                entry["title"],
                entry["author"],
                entry["description"],
                "",
                entry["language"],
                1 if entry["featured"] else 0,
                order,
            ),
        )
        mapping[(entry["title"], entry["author"])] = cursor.lastrowid

    return mapping


def seed_catalog():
    conn = get_connection()
    cursor = conn.cursor()
    ensure_catalog_schema(cursor)
    reset_catalog_tables(cursor)

    book_ids = _insert_catalog_books(cursor)
    replace_book_content(
        cursor,
        book_ids[(ALICE_TITLE, ALICE_AUTHOR)],
        _load_alice_chapters(ALICE_SOURCE),
    )
    replace_book_content(
        cursor,
        book_ids[(AMWAJ_AKMA_TITLE, AMWAJ_AKMA_AUTHOR)],
        _load_amwaj_akma_chapters(AMWAJ_AKMA_SOURCE),
    )

    conn.commit()
    conn.close()

    print(
        "Seeded catalog with "
        f"{len(ENGLISH_BOOKS)} English books and {len(ARABIC_BOOKS)} Arabic books."
    )
    print("Readable books in app: Alice's Adventures in Wonderland and the Arabic title.")


def main():
    parser = argparse.ArgumentParser(
        description="Reset the database catalog and seed it with curated books.",
    )
    parser.parse_args()
    seed_catalog()


if __name__ == "__main__":
    main()

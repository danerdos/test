import argparse
import json
from pathlib import Path

try:
    from .catalog_utils import ensure_catalog_schema, replace_book_content
    from .database import get_connection
except ImportError:
    from catalog_utils import ensure_catalog_schema, replace_book_content
    from database import get_connection

DEFAULT_BOOK_PATH = Path(r"C:\Users\DANER\Desktop\text\clean_book.json")
BOOK_TITLE = "Alice's Adventures in Wonderland"
BOOK_AUTHOR = "Lewis Carroll"
BOOK_DESCRIPTION = (
    "A classic fantasy novel following Alice as she falls into Wonderland, "
    "meeting unforgettable characters across twelve surreal chapters."
)
BOOK_LANGUAGE = "en"


def repair_text(value):
    if not isinstance(value, str):
        return value

    try:
        repaired = value.encode("latin1").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError):
        repaired = value

    return repaired.replace("\ufeff", "").strip()


def normalize_chapters(raw_chapters):
    cleaned = []
    for chapter in raw_chapters:
        cleaned.append(
            {
                "title": repair_text(chapter.get("title", "")),
                "content": [
                    repair_text(paragraph)
                    for paragraph in chapter.get("content", [])
                    if repair_text(paragraph)
                ],
            }
        )

    midpoint = len(cleaned) // 2
    headings = cleaned[:midpoint]
    full_chapters = cleaned[midpoint:]
    normalized = []

    for index, chapter in enumerate(full_chapters, start=1):
        short_title = ""
        if index - 1 < len(headings) and headings[index - 1]["content"]:
            short_title = headings[index - 1]["content"][0]

        normalized.append(
            {
                "chapter_number": index,
                "title": short_title or chapter["title"],
                "content": chapter["content"],
            }
        )

    return normalized


def upsert_book(cursor):
    cursor.execute(
        "SELECT id FROM books WHERE title = %s AND author = %s",
        (BOOK_TITLE, BOOK_AUTHOR),
    )
    existing = cursor.fetchone()

    if existing:
        book_id = existing[0]
        cursor.execute(
            """
            UPDATE books
            SET description = %s, cover_image = %s, language = %s
            WHERE id = %s
            """,
            (BOOK_DESCRIPTION, "", BOOK_LANGUAGE, book_id),
        )
        return book_id

    cursor.execute(
        """
        INSERT INTO books (title, author, description, cover_image, language)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (BOOK_TITLE, BOOK_AUTHOR, BOOK_DESCRIPTION, "", BOOK_LANGUAGE),
    )
    return cursor.lastrowid


def import_book(book_path: Path):
    with book_path.open("r", encoding="utf-8") as file:
        raw_book = json.load(file)

    chapters = normalize_chapters(raw_book["chapters"])

    conn = get_connection()
    cursor = conn.cursor()
    ensure_catalog_schema(cursor)
    book_id = upsert_book(cursor)
    replace_book_content(cursor, book_id, chapters)

    conn.commit()
    conn.close()

    chapter_count = len(chapters)
    page_count = sum(len(chapter["content"]) for chapter in chapters)
    print(
        f"Imported '{BOOK_TITLE}' as book_id={book_id} "
        f"with {chapter_count} chapters and {page_count} pages."
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--book-file",
        default=str(DEFAULT_BOOK_PATH),
        help="Path to the source JSON file.",
    )
    args = parser.parse_args()
    import_book(Path(args.book_file))


if __name__ == "__main__":
    main()

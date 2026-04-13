import argparse
import json
import re
from pathlib import Path

try:
    from .catalog_utils import ensure_catalog_schema, replace_book_content
    from .database import get_connection
except ImportError:
    from catalog_utils import ensure_catalog_schema, replace_book_content
    from database import get_connection

SOURCE_BOOK_PATH = Path(r"C:\Users\DANER\Desktop\text\book.json")
OUTPUT_DIR = Path(__file__).resolve().parent / "generated"
OUTPUT_JSON_PATH = OUTPUT_DIR / "amwaj_akma_app.json"
BOOK_TITLE = "\u0623\u0645\u0648\u0627\u062c \u0623\u0643\u0645\u0627"
BOOK_AUTHOR = "\u0639\u0645\u0631\u0648 \u0639\u0628\u062f \u0627\u0644\u062d\u0645\u064a\u062f"
BOOK_DESCRIPTION = (
    "\u0627\u0644\u062c\u0632\u0621 \u0627\u0644\u0623\u062e\u064a\u0631 \u0645\u0646 "
    "\u0633\u0644\u0633\u0644\u0629 \u0642\u0648\u0627\u0639\u062f \u062c\u0627\u0631\u062a\u064a\u0646\u060c "
    "\u062d\u064a\u062b \u062a\u062a\u0648\u0627\u0635\u0644 \u0623\u062d\u062f\u0627\u062b \u0622\u062f\u0645 "
    "\u0648\u063a\u0641\u0631\u0627\u0646 \u0648\u0628\u0642\u064a\u0629 \u0627\u0644\u0634\u062e\u0635\u064a\u0627\u062a "
    "\u0641\u064a \u0635\u0631\u0627\u0639 \u064a\u063a\u064a\u0631 \u0645\u0648\u0627\u0632\u064a\u0646 "
    "\u0627\u0644\u0642\u0648\u0649 \u0628\u064a\u0646 \u0627\u0644\u0646\u0633\u0627\u0644\u0649 "
    "\u0648\u0627\u0644\u0632\u0627\u0626\u0631\u064a\u0646 \u0648\u0627\u0644\u0623\u0634\u0631\u0627\u0641."
)
SECTION_PAGE_COUNT = 25
BOOK_LANGUAGE = "ar"

ARABIC_CHAR_PATTERN = re.compile(r"[\u0600-\u06FF]")
LATIN_PATTERN = re.compile(r"[A-Za-z]")
TRANSLATION_TABLE = str.maketrans(
    {
        "\u06A9": "\u0643",
        "\u06CC": "\u064A",
        "\u06BE": "\u0647",
        "\u06C1": "\u0647",
        "\u06D5": "\u0647",
        "\u200c": " ",
        "\ufeff": "",
        "\u00AB": '"',
        "\u00BB": '"',
        "\u2026": "...",
        "\u2014": "\u060C",
        "\u2013": "\u060C",
    }
)


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


def is_front_matter(page: str) -> bool:
    lowered = page.lower()
    markers = ["isbn", "email:", "www.", "booksjuice", "978-"]
    if any(marker in lowered for marker in markers):
        return True

    arabic_count = len(ARABIC_CHAR_PATTERN.findall(page))
    latin_count = len(LATIN_PATTERN.findall(page))
    return arabic_count > 0 and latin_count > 20


def clean_page_text(page: str) -> str:
    text = page.translate(TRANSLATION_TABLE)
    text = text.replace("\r", " ").replace("\n", " ")

    text = re.sub(r"https?://\S+|www\.\S+|\S+@\S+", " ", text)
    text = re.sub(r"\b(?:ISBN|Email)\b[:：]?\S*", " ", text, flags=re.IGNORECASE)
    text = re.sub(r"\[\s*\.?S\s*\.?B\s*\.?N[^\]]*\]", " ", text, flags=re.IGNORECASE)
    text = re.sub(r"^\s*[\d\u0660-\u0669]+\s*(?:[A-Za-z]+\s*)?", " ", text)
    text = re.sub(r"[A-Za-z]+(?:[\s@._:/+-]*[A-Za-z0-9]+)*", " ", text)
    text = re.sub(
        r"(?<=[\u0600-\u06FF])\s*[24]\s+(?=[\u0600-\u06FF])",
        " \u0641\u064A ",
        text,
    )
    text = re.sub(r"\s*[\u0660-\u06690-9]{1,3}\s*$", " ", text)
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([\u060C\u061B:.!?])", r"\1", text)
    text = re.sub(r"([\u060C\u061B:.!?]){2,}", r"\1", text)
    return text.strip(" -\u060C\u061B:.!?")


def build_sections(clean_pages: list[str]) -> list[dict]:
    sections = []

    for index in range(0, len(clean_pages), SECTION_PAGE_COUNT):
        section_pages = clean_pages[index : index + SECTION_PAGE_COUNT]
        if not section_pages:
            continue

        section_number = len(sections) + 1
        sections.append(
            {
                "chapter_number": section_number,
                "title": f"\u0627\u0644\u0642\u0633\u0645 {section_number}",
                "content": section_pages,
            }
        )

    return sections


def convert_book(book_path: Path) -> dict:
    with book_path.open("r", encoding="utf-8") as file:
        raw_data = json.load(file)

    raw_pages = raw_data[0]["pages"]
    clean_pages = []

    for index, page in enumerate(raw_pages):
        if index == 0 and is_front_matter(page):
            continue

        cleaned = clean_page_text(page)
        if cleaned and len(ARABIC_CHAR_PATTERN.findall(cleaned)) >= 40:
            clean_pages.append(cleaned)

    sections = build_sections(clean_pages)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    converted = {
        "title": BOOK_TITLE,
        "author": BOOK_AUTHOR,
        "description": BOOK_DESCRIPTION,
        "chapters": [
            {"title": section["title"], "content": section["content"]}
            for section in sections
        ],
    }

    OUTPUT_JSON_PATH.write_text(
        json.dumps(converted, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return converted


def import_book(book_path: Path):
    converted = convert_book(book_path)
    chapters = [
        {
            "chapter_number": chapter_number,
            "title": chapter["title"],
            "content": chapter["content"],
        }
        for chapter_number, chapter in enumerate(converted["chapters"], start=1)
    ]

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
        f"Imported book_id={book_id} "
        f"with {chapter_count} generated sections and {page_count} cleaned pages."
    )
    print(f"Saved cleaned import JSON to {OUTPUT_JSON_PATH}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--book-file",
        default=str(SOURCE_BOOK_PATH),
        help="Path to the raw Arabic pages JSON file.",
    )
    args = parser.parse_args()
    import_book(Path(args.book_file))


if __name__ == "__main__":
    main()

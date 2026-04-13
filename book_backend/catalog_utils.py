from __future__ import annotations


def _column_exists(cursor, table_name: str, column_name: str) -> bool:
    cursor.execute(f"SHOW COLUMNS FROM {table_name} LIKE '{column_name}'")
    return bool(cursor.fetchall())


def _index_exists(cursor, table_name: str, index_name: str) -> bool:
    cursor.execute(f"SHOW INDEX FROM {table_name} WHERE Key_name = '{index_name}'")
    return bool(cursor.fetchall())


def ensure_catalog_schema(cursor):
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS books (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255),
            author VARCHAR(255),
            description TEXT,
            cover_image VARCHAR(255),
            language VARCHAR(8) NOT NULL DEFAULT 'en',
            is_featured TINYINT(1) NOT NULL DEFAULT 0,
            sort_order INT NOT NULL DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS chapters (
            id INT AUTO_INCREMENT PRIMARY KEY,
            book_id INT NOT NULL,
            chapter_number INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_chapters_book
                FOREIGN KEY (book_id) REFERENCES books(id)
                ON DELETE CASCADE
        )
        """
    )
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS pages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            chapter_id INT NOT NULL,
            page_number INT NOT NULL,
            content LONGTEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_pages_chapter
                FOREIGN KEY (chapter_id) REFERENCES chapters(id)
                ON DELETE CASCADE
        )
        """
    )

    if not _column_exists(cursor, "books", "language"):
        cursor.execute(
            "ALTER TABLE books ADD COLUMN language VARCHAR(8) NOT NULL DEFAULT 'en'"
        )
    if not _column_exists(cursor, "books", "is_featured"):
        cursor.execute(
            "ALTER TABLE books ADD COLUMN is_featured TINYINT(1) NOT NULL DEFAULT 0"
        )
    if not _column_exists(cursor, "books", "sort_order"):
        cursor.execute("ALTER TABLE books ADD COLUMN sort_order INT NOT NULL DEFAULT 0")

    ensure_audio_table(cursor)


def ensure_audio_table(cursor):
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS chapter_audio (
            id INT AUTO_INCREMENT PRIMARY KEY,
            chapter_id INT NOT NULL,
            voice_name VARCHAR(64) NOT NULL DEFAULT 'Rachel',
            audio_path VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ON UPDATE CURRENT_TIMESTAMP,
            CONSTRAINT fk_chapter_audio_chapter
                FOREIGN KEY (chapter_id) REFERENCES chapters(id)
                ON DELETE CASCADE,
            CONSTRAINT uq_chapter_audio_voice UNIQUE (chapter_id, voice_name)
        )
        """
    )

    if not _column_exists(cursor, "chapter_audio", "voice_name"):
        cursor.execute(
            "ALTER TABLE chapter_audio ADD COLUMN voice_name VARCHAR(64) NOT NULL DEFAULT 'Rachel'"
        )

    for legacy_index in ("chapter_id", "chapter_id_UNIQUE"):
        try:
            cursor.execute(f"ALTER TABLE chapter_audio DROP INDEX {legacy_index}")
        except Exception:
            pass

    if not _index_exists(cursor, "chapter_audio", "uq_chapter_audio_voice"):
        cursor.execute(
            "ALTER TABLE chapter_audio "
            "ADD CONSTRAINT uq_chapter_audio_voice UNIQUE (chapter_id, voice_name)"
        )


def _first_column(row):
    if isinstance(row, dict):
        return next(iter(row.values()))
    return row[0]


def clear_existing_book_content(cursor, book_id: int):
    cursor.execute("SELECT id FROM chapters WHERE book_id = %s", (book_id,))
    chapter_ids = [_first_column(row) for row in cursor.fetchall()]

    if chapter_ids:
        placeholders = ", ".join(["%s"] * len(chapter_ids))
        cursor.execute(
            f"DELETE FROM chapter_audio WHERE chapter_id IN ({placeholders})",
            tuple(chapter_ids),
        )
        cursor.execute(
            f"DELETE FROM pages WHERE chapter_id IN ({placeholders})",
            tuple(chapter_ids),
        )

    cursor.execute("DELETE FROM chapters WHERE book_id = %s", (book_id,))


def replace_book_content(cursor, book_id: int, chapters):
    clear_existing_book_content(cursor, book_id)

    for chapter_number, chapter in enumerate(chapters, start=1):
        resolved_number = chapter.get("chapter_number", chapter_number)
        cursor.execute(
            """
            INSERT INTO chapters (book_id, chapter_number, title)
            VALUES (%s, %s, %s)
            """,
            (book_id, resolved_number, chapter["title"]),
        )
        chapter_id = cursor.lastrowid

        for page_number, paragraph in enumerate(chapter.get("content", []), start=1):
            cursor.execute(
                """
                INSERT INTO pages (chapter_id, page_number, content)
                VALUES (%s, %s, %s)
                """,
                (chapter_id, page_number, paragraph),
            )


def reset_catalog_tables(cursor):
    ensure_catalog_schema(cursor)

    for table_name in ("chapter_audio", "pages", "chapters", "books"):
        cursor.execute(f"DELETE FROM {table_name}")

    for table_name in ("chapter_audio", "pages", "chapters", "books"):
        try:
            cursor.execute(f"ALTER TABLE {table_name} AUTO_INCREMENT = 1")
        except Exception:
            pass

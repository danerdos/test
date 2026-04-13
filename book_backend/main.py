from pathlib import Path

import os
import re

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from gtts import gTTS

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None

try:
    from elevenlabs import VoiceSettings
    from elevenlabs.client import ElevenLabs
except ImportError:
    VoiceSettings = None
    ElevenLabs = None

try:
    from .catalog_utils import ensure_audio_table, ensure_catalog_schema
    from .database import get_connection
except ImportError:
    from catalog_utils import ensure_audio_table, ensure_catalog_schema
    from database import get_connection

BASE_DIR = Path(__file__).resolve().parent
MEDIA_DIR = BASE_DIR / "media"
AUDIO_DIR = MEDIA_DIR / "audio"
AUDIO_DIR.mkdir(parents=True, exist_ok=True)

if load_dotenv is not None:
    load_dotenv(BASE_DIR / ".env")
    load_dotenv(BASE_DIR.parent / ".env")

DEFAULT_VOICE_NAME = os.getenv("ELEVENLABS_VOICE", "Rachel")
ELEVENLABS_MODEL_ID = os.getenv("ELEVENLABS_MODEL_ID", "eleven_multilingual_v2")
VOICE_IDS = {
    "Rachel": "21m00Tcm4TlvDq8ikWAM",
    "Adam": "pNInz6obpgDQGcFmaJgB",
}
AUDIO_FORMAT_VERSION = "v3"
MAX_TTS_CHARS = 9000
ARABIC_CHAR_PATTERN = re.compile(r"[\u0600-\u06FF]")

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/media", StaticFiles(directory=str(MEDIA_DIR)), name="media")


@app.on_event("startup")
def startup_event():
    conn = get_connection()
    cursor = conn.cursor()
    ensure_catalog_schema(cursor)
    conn.commit()
    conn.close()


def get_chapter_with_pages(cursor, chapter_id: int):
    cursor.execute(
        """
        SELECT c.id, c.book_id, c.chapter_number, c.title, b.title AS book_title
        FROM chapters c
        JOIN books b ON b.id = c.book_id
        WHERE c.id = %s
        """,
        (chapter_id,),
    )
    chapter = cursor.fetchone()
    if not chapter:
        return None, []

    cursor.execute(
        """
        SELECT page_number, content
        FROM pages
        WHERE chapter_id = %s
        ORDER BY page_number
        """,
        (chapter_id,),
    )
    pages = cursor.fetchall()
    return chapter, pages


def build_audio_filename(chapter: dict, voice_name: str) -> str:
    voice_slug = voice_name.lower().replace(" ", "_")
    return (
        f"book_{chapter['book_id']}_chapter_{chapter['chapter_number']}_"
        f"{voice_slug}_{AUDIO_FORMAT_VERSION}.mp3"
    )


def build_audio_text(chapter: dict, pages: list[dict]) -> str:
    raw_page_text = [page["content"] for page in pages if page["content"]]
    intro_language = detect_tts_language(
        " ".join([chapter["book_title"], chapter["title"], *raw_page_text])
    )

    if intro_language == "ar":
        title_line = (
            f"{chapter['book_title']}. "
            f"\u0627\u0644\u0641\u0635\u0644 {chapter['chapter_number']}. "
            f"{chapter['title']}"
        )
    else:
        title_line = (
            f"{chapter['book_title']}. Chapter {chapter['chapter_number']}. "
            f"{chapter['title']}"
        )

    page_text = [
        normalize_tts_text(page["content"])
        for page in pages
        if page["content"]
    ]
    return "\n\n".join([title_line, *page_text]).strip()


def normalize_tts_text(text: str) -> str:
    cleaned = text.replace("\r", " ").replace("\n", " ")
    cleaned = re.sub(r"_([^_]+)_", r"\1", cleaned)
    cleaned = cleaned.replace("_", " ")
    cleaned = cleaned.replace("*", " ")
    cleaned = cleaned.replace("â€”", ", ")
    cleaned = cleaned.replace("â€“", ", ")
    cleaned = cleaned.replace("—", ", ")
    cleaned = cleaned.replace("–", ", ")
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned.strip()


def detect_tts_language(text: str) -> str:
    return "ar" if len(ARABIC_CHAR_PATTERN.findall(text)) >= 20 else "en"


def split_text_for_tts(text: str, max_chars: int = MAX_TTS_CHARS) -> list[str]:
    paragraphs = [part.strip() for part in text.split("\n\n") if part.strip()]
    chunks = []
    current = ""

    for paragraph in paragraphs:
        candidate = paragraph if not current else f"{current}\n\n{paragraph}"
        if len(candidate) <= max_chars:
            current = candidate
            continue

        if current:
            chunks.append(current)
            current = ""

        if len(paragraph) <= max_chars:
            current = paragraph
            continue

        sentences = re.split(r"(?<=[.!?])\s+", paragraph)
        sentence_chunk = ""
        for sentence in sentences:
            if not sentence:
                continue
            sentence_candidate = (
                sentence if not sentence_chunk else f"{sentence_chunk} {sentence}"
            )
            if len(sentence_candidate) <= max_chars:
                sentence_chunk = sentence_candidate
                continue

            if sentence_chunk:
                chunks.append(sentence_chunk)

            if len(sentence) <= max_chars:
                sentence_chunk = sentence
                continue

            words = sentence.split()
            word_chunk = ""
            for word in words:
                word_candidate = word if not word_chunk else f"{word_chunk} {word}"
                if len(word_candidate) <= max_chars:
                    word_chunk = word_candidate
                else:
                    if word_chunk:
                        chunks.append(word_chunk)
                    word_chunk = word
            sentence_chunk = word_chunk

        if sentence_chunk:
            current = sentence_chunk

    if current:
        chunks.append(current)

    return chunks


def strip_leading_id3_tag(audio_bytes: bytes) -> bytes:
    if len(audio_bytes) < 10 or audio_bytes[:3] != b"ID3":
        return audio_bytes

    tag_size = (
        ((audio_bytes[6] & 0x7F) << 21)
        | ((audio_bytes[7] & 0x7F) << 14)
        | ((audio_bytes[8] & 0x7F) << 7)
        | (audio_bytes[9] & 0x7F)
    )
    return audio_bytes[10 + tag_size :]


def get_elevenlabs_client():
    api_key = os.getenv("ELEVENLABS_API_KEY", "").strip()
    if not api_key or ElevenLabs is None:
        return None
    return ElevenLabs(api_key=api_key)


def resolve_voice_id(voice_name: str) -> str:
    default_voice_id = VOICE_IDS.get(DEFAULT_VOICE_NAME, VOICE_IDS["Rachel"])
    return VOICE_IDS.get(voice_name, default_voice_id)


def save_audio_with_elevenlabs(text: str, output_path: Path, voice_name: str):
    client = get_elevenlabs_client()
    if client is None or VoiceSettings is None:
        raise RuntimeError("ElevenLabs SDK or API key is not available")

    with output_path.open("wb") as file:
        for index, text_chunk in enumerate(split_text_for_tts(text)):
            response = client.text_to_speech.convert(
                voice_id=resolve_voice_id(voice_name),
                output_format="mp3_44100_128",
                text=text_chunk,
                model_id=ELEVENLABS_MODEL_ID,
                voice_settings=VoiceSettings(
                    stability=0.35,
                    similarity_boost=0.8,
                    style=0.2,
                    use_speaker_boost=True,
                    speed=1.0,
                ),
            )

            audio_bytes = b"".join(chunk for chunk in response if chunk)
            if index > 0:
                audio_bytes = strip_leading_id3_tag(audio_bytes)
            file.write(audio_bytes)


def save_audio_with_gtts(text: str, output_path: Path):
    language = detect_tts_language(text)

    with output_path.open("wb") as file:
        for index, text_chunk in enumerate(split_text_for_tts(text, max_chars=4000)):
            temp_path = output_path.parent / f".gtts_{output_path.stem}_{index}.mp3"
            gTTS(text=text_chunk, lang=language).save(str(temp_path))
            audio_bytes = temp_path.read_bytes()
            temp_path.unlink(missing_ok=True)
            if index > 0:
                audio_bytes = strip_leading_id3_tag(audio_bytes)
            file.write(audio_bytes)


def save_audio_with_fallback(text: str, output_path: Path, voice_name: str):
    elevenlabs_error = None
    try:
        save_audio_with_elevenlabs(text, output_path, voice_name)
        return "elevenlabs"
    except Exception as error:
        elevenlabs_error = str(error)

    try:
        save_audio_with_gtts(text, output_path)
        return "gtts"
    except Exception as error:
        raise RuntimeError(
            "Audio generation failed. "
            f"ElevenLabs error: {elevenlabs_error}. "
            f"gTTS error: {error}"
        ) from error


@app.get("/books")
def get_books():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    ensure_catalog_schema(cursor)
    cursor.execute(
        """
        SELECT
            b.id,
            b.title,
            b.author,
            b.description,
            b.cover_image,
            b.created_at,
            COALESCE(b.language, 'en') AS language,
            COALESCE(b.is_featured, 0) AS is_featured,
            COALESCE(b.sort_order, 0) AS sort_order,
            COALESCE(stats.chapter_count, 0) AS chapter_count,
            COALESCE(stats.page_count, 0) AS page_count,
            CASE
                WHEN COALESCE(stats.chapter_count, 0) > 0 THEN TRUE
                ELSE FALSE
            END AS is_readable
        FROM books b
        LEFT JOIN (
            SELECT
                c.book_id,
                COUNT(DISTINCT c.id) AS chapter_count,
                COUNT(p.id) AS page_count
            FROM chapters c
            LEFT JOIN pages p ON p.chapter_id = c.id
            GROUP BY c.book_id
        ) AS stats ON stats.book_id = b.id
        ORDER BY
            COALESCE(b.is_featured, 0) DESC,
            CASE
                WHEN COALESCE(stats.chapter_count, 0) > 0 THEN 1
                ELSE 0
            END DESC,
            COALESCE(b.sort_order, 0) ASC,
            b.title ASC
        """
    )
    books = cursor.fetchall()

    conn.close()
    return books


@app.get("/books/summary")
def get_books_summary():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    ensure_catalog_schema(cursor)
    cursor.execute(
        """
        SELECT
            COUNT(*) AS total_books,
            SUM(
                CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM chapters c
                        WHERE c.book_id = b.id
                    ) THEN 1
                    ELSE 0
                END
            ) AS readable_books,
            SUM(CASE WHEN COALESCE(b.language, 'en') = 'en' THEN 1 ELSE 0 END) AS english_books,
            SUM(CASE WHEN COALESCE(b.language, 'en') = 'ar' THEN 1 ELSE 0 END) AS arabic_books
        FROM books b
        """
    )
    summary = cursor.fetchone()
    conn.close()
    return summary


@app.get("/books/{book_id}/chapters")
def get_chapters(book_id: int):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM chapters WHERE book_id = %s ORDER BY chapter_number",
        (book_id,),
    )
    chapters = cursor.fetchall()

    conn.close()
    return chapters


@app.get("/chapters/{chapter_id}/pages")
def get_pages(chapter_id: int):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM pages WHERE chapter_id = %s ORDER BY page_number",
        (chapter_id,),
    )
    pages = cursor.fetchall()

    conn.close()
    return pages


@app.get("/chapters/{chapter_id}/audio")
def get_chapter_audio(
    chapter_id: int,
    request: Request,
    voice: str = DEFAULT_VOICE_NAME,
):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    ensure_audio_table(cursor)
    conn.commit()

    chapter, pages = get_chapter_with_pages(cursor, chapter_id)
    if not chapter:
        conn.close()
        raise HTTPException(status_code=404, detail="Chapter not found")

    if not pages:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="No readable content found for this chapter",
        )

    filename = build_audio_filename(chapter, voice)
    audio_file = AUDIO_DIR / filename
    relative_audio_path = f"audio/{filename}"

    cursor.execute(
        """
        SELECT audio_path
        FROM chapter_audio
        WHERE chapter_id = %s AND voice_name = %s
        """,
        (chapter_id, voice),
    )
    cached_audio = cursor.fetchone()
    audio_ready = bool(cached_audio) and audio_file.exists()

    if not audio_ready:
        full_text = build_audio_text(chapter, pages)
        try:
            tts_provider = save_audio_with_fallback(full_text, audio_file, voice)
        except RuntimeError as error:
            conn.close()
            raise HTTPException(status_code=503, detail=str(error)) from error

        cursor.execute(
            """
            INSERT INTO chapter_audio (chapter_id, voice_name, audio_path)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE
                audio_path = VALUES(audio_path)
            """,
            (chapter_id, voice, relative_audio_path),
        )
        conn.commit()
    else:
        tts_provider = "cache"

    audio_url = f"{str(request.base_url).rstrip('/')}/media/{relative_audio_path}"
    response = {
        "chapter_id": chapter_id,
        "chapter_number": chapter["chapter_number"],
        "title": chapter["title"],
        "audio_url": audio_url,
        "cached": audio_ready,
        "voice": voice,
        "provider": tts_provider,
    }

    conn.close()
    return response

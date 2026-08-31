#!/usr/bin/env python3
"""Fetch a YouTube video's metadata and transcript via yt-dlp.

WebFetch cannot read youtube.com usefully (JS-rendered; at best the description).
yt-dlp reads the metadata and the caption tracks — official subtitles when the
uploader provided them, auto-generated ones otherwise — without downloading the
video itself.

Usage:  fetch_youtube.py <youtube-url> [--langs ja,en]
Prints a plain-text rendering (metadata + timestamped transcript) to stdout;
exits non-zero on failure (not a YouTube URL, yt-dlp missing, private/removed
video, or no captions in the video's original language). By default, select the
original language reported by YouTube; --langs explicitly overrides it.
"""
import argparse
import glob
import html
import json
import os
import re
import shutil
import subprocess
import tempfile
from typing import Any, Dict, List, Optional, Tuple

# One timestamp marker per this many seconds of transcript.
MARKER_INTERVAL = 30
Metadata = Dict[str, Any]
Cue = Tuple[float, str]


def video_id(url: str) -> Optional[str]:
    """Return the 11-char video id for any common YouTube URL shape, else None."""
    patterns = [
        r"youtu\.be/([\w-]{11})",
        r"[?&]v=([\w-]{11})",
        r"/(?:embed|shorts|live|v)/([\w-]{11})",
    ]
    for p in patterns:
        m = re.search(p, url)
        if m:
            return m.group(1)
    return None


def run_yt_dlp(args: List[str]) -> subprocess.CompletedProcess:
    if not shutil.which("yt-dlp"):
        raise SystemExit("yt-dlp not found on PATH")
    return subprocess.run(
        ["yt-dlp", *args], capture_output=True, text=True, timeout=120
    )


def fetch_metadata(url: str) -> Metadata:
    out = run_yt_dlp(["--skip-download", "--dump-json", "--no-warnings", url])
    if out.returncode != 0:
        raise SystemExit(f"yt-dlp failed: {out.stderr.strip()[:400]}")
    try:
        return json.loads(out.stdout.splitlines()[0])
    except (json.JSONDecodeError, IndexError):
        raise SystemExit("yt-dlp returned no metadata")


def original_caption_languages(meta: Metadata) -> List[str]:
    """Return the best caption track for the video's original language."""
    subtitles = meta.get("subtitles") or {}
    automatic = meta.get("automatic_captions") or {}
    language = meta.get("language")

    if isinstance(language, str) and language:
        language_codes = [language]
        base_language = language.split("-", 1)[0]
        if base_language != language:
            language_codes.append(base_language)

        # Prefer uploader-provided captions in the video's original language.
        for code in language_codes:
            if code in subtitles:
                return [code]

        # YouTube marks the untranslated automatic track with an -orig suffix.
        for code in language_codes:
            original_code = f"{code}-orig"
            if original_code in automatic:
                return [original_code]

        # Some videos expose the original automatic track without -orig.
        for code in language_codes:
            if code in automatic:
                return [code]

    original_automatic = sorted(
        code for code in automatic if code.endswith("-orig")
    )
    if len(original_automatic) == 1:
        return original_automatic

    # A sole manual track is the safest fallback when metadata omits language.
    manual_languages = sorted(subtitles)
    if len(manual_languages) == 1:
        return manual_languages

    return []


def fetch_subtitle_file(
    url: str, langs: List[str], tmpdir: str, meta: Metadata
) -> Tuple[str, str, bool]:
    """Download caption tracks; return (path, lang, is_auto) for the best match."""
    out = run_yt_dlp([
        "--skip-download", "--no-warnings",
        "--write-subs", "--write-auto-subs",
        "--sub-langs", ",".join(langs),
        "--sub-format", "vtt",
        "-o", os.path.join(tmpdir, "sub.%(ext)s"),
        url,
    ])
    files = glob.glob(os.path.join(tmpdir, "sub.*.vtt"))
    if not files:
        raise SystemExit(
            "no captions available in "
            f"{', '.join(langs)} (yt-dlp: {out.stderr.strip()[:200]})"
        )
    # yt-dlp names files sub.<lang>.vtt; prefer the earliest requested language.
    def rank(path: str) -> int:
        lang = os.path.basename(path).split(".")[1]
        return langs.index(lang) if lang in langs else len(langs)

    best = min(files, key=rank)
    lang = os.path.basename(best).split(".")[1]
    # yt-dlp falls back to the auto-generated track when the uploader provided
    # no manual one, and the file itself does not say which it got; the metadata
    # does, by listing manual tracks separately from automatic_captions.
    is_auto = lang not in (meta.get("subtitles") or {})
    return best, lang, is_auto


def parse_vtt(path: str) -> List[Cue]:
    """Parse a VTT file into [(start_seconds, text)], deduped and tag-stripped."""
    cue_re = re.compile(
        r"^(\d{2}:)?\d{2}:\d{2}[.,]\d{3}\s+-->\s+(\d{2}:)?\d{2}:\d{2}[.,]\d{3}"
    )
    cues, start, buf = [], None, []

    def flush() -> None:
        if start is None:
            return
        text = " ".join(buf).strip()
        if text:
            cues.append((start, text))

    with open(path, encoding="utf-8") as f:
        for raw in f:
            line = raw.rstrip("\n")
            if cue_re.match(line):
                flush()
                start, buf = to_seconds(line.split("-->")[0].strip()), []
                continue
            if not line.strip() or line.startswith(("WEBVTT", "Kind:", "Language:", "NOTE")):
                continue
            if start is None:
                continue
            # Strip karaoke timing tags (<00:00:01.000><c>word</c>) and entities.
            clean = re.sub(r"<[^>]+>", "", line)
            clean = html.unescape(clean).strip()
            if clean:
                buf.append(clean)
    flush()
    return dedupe(cues)


def to_seconds(stamp: str) -> float:
    stamp = stamp.replace(",", ".").split(" ")[0]
    parts = [float(p) for p in stamp.split(":")]
    while len(parts) < 3:
        parts.insert(0, 0.0)
    return parts[0] * 3600 + parts[1] * 60 + parts[2]


def dedupe(cues: List[Cue]) -> List[Cue]:
    """Drop the rolling-caption repetition of auto-generated tracks.

    Auto captions re-emit the previous cue's text as the head of the next cue,
    so consecutive cues overlap heavily. Keep a cue only for the part that is
    not already covered by what has been emitted.
    """
    result = []
    for start, text in cues:
        if not result:
            result.append((start, text))
            continue
        prev = result[-1][1]
        if text == prev or text in prev:
            continue
        if text.startswith(prev):
            result[-1] = (result[-1][0], text)
            continue
        # Trim the longest prefix of `text` that is a suffix of `prev`.
        words, prev_words = text.split(), prev.split()
        for n in range(min(len(words), len(prev_words)), 0, -1):
            if prev_words[-n:] == words[:n]:
                text = " ".join(words[n:])
                break
        if text.strip():
            result.append((start, text.strip()))
    return result


def hhmmss(seconds: Optional[float]) -> str:
    seconds = int(seconds or 0)
    h, m, s = seconds // 3600, (seconds % 3600) // 60, seconds % 60
    return f"{h}:{m:02d}:{s:02d}" if h else f"{m}:{s:02d}"


def render_transcript(cues: List[Cue]) -> str:
    """Flow the cues into paragraphs, each headed by a [mm:ss] marker."""
    blocks, buf, marker = [], [], None
    for start, text in cues:
        if marker is None or start - marker >= MARKER_INTERVAL:
            if buf:
                blocks.append(f"[{hhmmss(marker)}] " + " ".join(buf))
            marker, buf = start, []
        buf.append(text)
    if buf:
        blocks.append(f"[{hhmmss(marker)}] " + " ".join(buf))
    return "\n\n".join(blocks)


def render(meta: Metadata, lang: str, is_auto: bool, cues: List[Cue]) -> str:
    upload = meta.get("upload_date") or ""
    if len(upload) == 8:
        upload = f"{upload[:4]}-{upload[4:6]}-{upload[6:]}"
    lines = [
        f"Title: {meta.get('title', '')}",
        f"Channel: {meta.get('uploader') or meta.get('channel') or ''}",
        f"Published: {upload}",
        f"Duration: {hhmmss(meta.get('duration'))}",
        f"URL: {meta.get('webpage_url', '')}",
        f"Video language: {meta.get('language') or 'unknown'}",
        f"Captions: {lang} ({'auto-generated' if is_auto else 'official'})",
        "",
        "Description:",
        (meta.get("description") or "").strip(),
        "",
        "Transcript:",
        render_transcript(cues),
    ]
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("url")
    ap.add_argument(
        "--langs",
        help=(
            "comma-separated caption languages, most preferred first; "
            "overrides original-language detection"
        ),
    )
    ns = ap.parse_args()

    if not video_id(ns.url):
        raise SystemExit("not a YouTube video URL")
    meta = fetch_metadata(ns.url)
    if ns.langs:
        langs = [lang.strip() for lang in ns.langs.split(",") if lang.strip()]
    else:
        langs = original_caption_languages(meta)
    if not langs:
        raise SystemExit(
            "could not determine captions in the video's original language; "
            "pass --langs to override"
        )

    with tempfile.TemporaryDirectory() as tmpdir:
        path, lang, is_auto = fetch_subtitle_file(ns.url, langs, tmpdir, meta)
        cues = parse_vtt(path)
    if not cues:
        raise SystemExit(f"caption track {lang} was empty")
    print(render(meta, lang, is_auto, cues))


if __name__ == "__main__":
    main()

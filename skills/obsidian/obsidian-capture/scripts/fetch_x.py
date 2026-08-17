#!/usr/bin/env python3
"""Fetch a public X (Twitter) post via the syndication endpoint.

WebFetch cannot read x.com/twitter.com (JS-only, bot-blocked). This uses the
public `cdn.syndication.twimg.com/tweet-result` endpoint, which needs no auth
and returns the post as JSON. Only curl + the Python stdlib are required.

Usage:  fetch_x.py <x-or-twitter-url>
Prints a plain-text rendering of the post to stdout; exits non-zero on failure
(deleted / protected / not-found post, or a non-status URL).
"""
import html
import json
import math
import re
import subprocess
import sys


def is_x_url(url: str) -> bool:
    return bool(re.search(r"https?://(?:[\w.-]+\.)?(?:x|twitter|fxtwitter|vxtwitter|nitter)\.com/", url, re.I))


def extract_id(url: str):
    m = re.search(r"/status(?:es)?/(\d+)", url)
    return m.group(1) if m else None


def make_token(tid: str) -> str:
    """Replicate react-tweet's getToken: ((id/1e15)*PI).toString(36) minus 0s/dots."""
    num = (int(tid) / 1e15) * math.pi
    digits = "0123456789abcdefghijklmnopqrstuvwxyz"
    intpart = int(num)
    frac = num - intpart
    if intpart == 0:
        s = "0"
    else:
        s, n = "", intpart
        while n > 0:
            s = digits[n % 36] + s
            n //= 36
    if frac > 0:
        s += "."
        for _ in range(24):
            frac *= 36
            d = int(frac)
            s += digits[d]
            frac -= d
            if frac <= 0:
                break
    return re.sub(r"(0+|\.)", "", s)


def fetch(tid: str) -> dict:
    token = make_token(tid)
    api = (
        "https://cdn.syndication.twimg.com/tweet-result"
        f"?id={tid}&token={token}&lang=en"
    )
    out = subprocess.run(
        [
            "curl", "-sSL", "--max-time", "25",
            "-H", "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
            api,
        ],
        capture_output=True, text=True,
    )
    if out.returncode != 0:
        raise SystemExit(f"curl failed: {out.stderr.strip()}")
    body = out.stdout.strip()
    if not body or body == "{}" or body == "null":
        raise SystemExit("post not available (deleted, protected, or not found)")
    try:
        return json.loads(body)
    except json.JSONDecodeError:
        raise SystemExit(f"unexpected response: {body[:200]}")


def post_text(t: dict) -> str:
    """Full text: prefer note_tweet (long-form >280 chars) over the truncated text."""
    note = (
        t.get("note_tweet", {})
        .get("note_tweet_results", {})
        .get("result", {})
        .get("text")
    )
    return html.unescape(note or t.get("text", ""))


def render(t: dict) -> str:
    user = t.get("user", {})
    name = user.get("name", "")
    screen = user.get("screen_name", "")
    lines = [
        f"Author: {name} (@{screen})" if screen else f"Author: {name}",
        f"Posted: {t.get('created_at', '')}",
        f"URL: https://x.com/{screen}/status/{t.get('id_str', '')}",
        "",
        post_text(t),
    ]
    # Expanded links referenced in the post
    urls = [u.get("expanded_url") for u in t.get("entities", {}).get("urls", []) if u.get("expanded_url")]
    if urls:
        lines += ["", "Links:"] + [f"- {u}" for u in urls]
    # Quoted post
    q = t.get("quoted_tweet")
    if q:
        qu = q.get("user", {})
        lines += [
            "",
            f"Quoting @{qu.get('screen_name', '')}:",
            post_text(q),
        ]
    return "\n".join(lines)


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: fetch_x.py <x-or-twitter-url>")
    url = sys.argv[1]
    if not is_x_url(url):
        raise SystemExit("not an x.com/twitter.com URL")
    tid = extract_id(url)
    if not tid:
        raise SystemExit("no status id in URL (X Articles / profile pages are unsupported)")
    print(render(fetch(tid)))


if __name__ == "__main__":
    main()

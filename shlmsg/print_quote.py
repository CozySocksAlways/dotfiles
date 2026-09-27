#! /usr/bin/python
import json
import random
import shutil
import textwrap
from pathlib import Path


BOLD = "\033[1m"
DIM = "\033[2m"
ITALIC = "\033[3m"

CYAN = "\033[36m"

RESET = "\033[0m"

MAX_WIDTH = 60
INDENT = "  "


def load_quote():
    quotes = json.loads((Path(__file__).parent / "quotes.json").read_text())
    quote = random.choice(quotes)
    # Plain strings are allowed for quotes without an author
    if isinstance(quote, str):
        return quote, ""
    return quote["text"], quote.get("author", "")


def main():
    text, author = load_quote()
    width = min(MAX_WIDTH, shutil.get_terminal_size().columns - 8)
    lines = textwrap.wrap(text, width)
    author = f"— {author}" if author else ""

    # Pad before colouring, otherwise escape codes skew the right border
    left = f"{INDENT}{DIM}│{RESET}  "
    right = f"  {DIM}│{RESET}"
    bar = "─" * (width + 4)

    print()
    print(f"{INDENT}{DIM}╭{bar}╮{RESET}")
    for line in lines:
        print(f"{left}{ITALIC}{CYAN}{line:<{width}}{RESET}{right}")
    if author:
        print(f"{left}{BOLD}{author:>{width}}{RESET}{right}")
    print(f"{INDENT}{DIM}╰{bar}╯{RESET}")
    print()


if __name__ == "__main__":
    main()

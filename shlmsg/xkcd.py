#! /usr/bin/python
"""Show a random xkcd comic in the terminal.

Usage: xkcd.py [NUM]              render title, comic and alt text via kitten icat
       xkcd.py [NUM] | kitten icat  write only the image bytes to stdout
"""
import fcntl
import json
import random
import shutil
import struct
import subprocess
import sys
import termios
import textwrap
import urllib.request

from print_quote import BOLD, CYAN, DIM, INDENT, ITALIC, MAX_WIDTH, RESET

WHITE = "\033[97m"

API = "https://xkcd.com/{}info.0.json"
TIMEOUT = 3
# Comics taller than this fraction of the window are skipped for a random pick
MAX_HEIGHT = 0.6
TRIES = 5


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "xkcd.py"})
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        return resp.read()


def comic_info(num=""):
    return json.loads(fetch(API.format(f"{num}/" if num else "")))


def strip_icc(data):
    """Drop the iCCP chunk from a PNG; kitten icat can't decode Gray ICC profiles."""
    sig = b"\x89PNG\r\n\x1a\n"
    if not data.startswith(sig):
        return data
    out, pos = [sig], len(sig)
    while pos < len(data):
        length = int.from_bytes(data[pos:pos + 4], "big")
        end = pos + 12 + length  # length + type + data + crc
        if data[pos + 4:pos + 8] != b"iCCP":
            out.append(data[pos:end])
        pos = end
    return b"".join(out)


def image_size(data):
    """(width, height) in pixels for PNG and GIF, None for anything else."""
    if data.startswith(b"\x89PNG"):
        return struct.unpack(">II", data[16:24])
    if data.startswith(b"GIF"):
        return struct.unpack("<HH", data[6:10])
    return None


def window_pixels():
    """(width, height) of the terminal window in pixels, None if unknown."""
    try:
        with open("/dev/tty") as tty:
            _, _, xpix, ypix = struct.unpack(
                "HHHH", fcntl.ioctl(tty, termios.TIOCGWINSZ, b"\0" * 8))
    except OSError:
        return None
    return (xpix, ypix) if xpix and ypix else None


def random_comic():
    """Pick a random comic, preferring ones that fit the window."""
    latest = comic_info()["num"]
    window = window_pixels()
    for _ in range(TRIES):
        num = random.randint(1, latest)
        # There is no comic 404
        if num == 404:
            continue
        info = comic_info(num)
        img = fetch(info["img"])
        size = image_size(img)
        if not window or not size or size[1] <= window[1] * MAX_HEIGHT:
            break
    return info, img


def render(info, img):
    print(f"\n{INDENT}{BOLD}{CYAN}xkcd #{info['num']}{RESET}"
          f"{DIM} · {RESET}{BOLD}{info['safe_title']}{RESET}\n", flush=True)
    subprocess.run(["kitten", "icat", "--align", "left"], input=img, check=True)
    width = min(MAX_WIDTH, shutil.get_terminal_size().columns - 2 * len(INDENT))
    print()
    for line in textwrap.wrap(info["alt"], width):
        print(f"{INDENT}{ITALIC}{WHITE}{line}{RESET}")
    print()


def main():
    if len(sys.argv) > 1:
        info = comic_info(int(sys.argv[1]))
        img = fetch(info["img"])
    else:
        info, img = random_comic()
    img = strip_icc(img)

    if sys.stdout.isatty():
        render(info, img)
    else:
        print(f"#{info['num']}: {info['safe_title']}", file=sys.stderr)
        print(info["alt"], file=sys.stderr)
        sys.stdout.buffer.write(img)


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError):
        # Offline or no graphics support: stay quiet so shell startup isn't noisy
        sys.exit(1)

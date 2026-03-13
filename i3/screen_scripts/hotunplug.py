#!/usr/bin/python3

import subprocess
import logging

logging.basicConfig(
    filename="/tmp/hotunplug.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%d-%m-%Y %I:%M:%S %p",
)
logger = logging.getLogger("SyncLogger")


def parse_xrandr_output(xrandr_output):
    monitors = {}
    current_monitor = None

    for line in xrandr_output.splitlines():
        line = line.strip()
        if not line:
            continue

        # Monitor line: "eDP-1 connected primary 1920x1200+0+0 ..."
        parts = line.split()
        if len(parts) >= 2 and parts[1] in ("connected", "disconnected"):
            name = parts[0]
            status = parts[1]
            if status == "connected":
                # Check for "primary"
                primary = "primary" in line
                # Try to get current resolution
                cur_res = None
                cur_match = [p for p in parts if "+" in p and "x" in p]
                if cur_match:
                    res_str = cur_match[0].split("+")[0]
                    w, h = map(int, res_str.split("x"))
                    cur_res = (w, h)
                monitors[name] = {
                    "primary": primary,
                    "current": cur_res,
                    "preferred": None,
                    "resolutions": [],
                }
                current_monitor = name
            else:
                current_monitor = None
            continue

        # Resolution lines (only for connected monitors)
        if current_monitor and line[0].isdigit():
            res = line.split()[0]
            w, h = map(int, res.split("x"))
            monitors[current_monitor]["resolutions"].append((w, h))
            if "*" in line:
                monitors[current_monitor]["preferred"] = (w, h)

    return monitors


def main():
    try:
        result = subprocess.run(
            ["xrandr", "--listmonitors"],
            check=True,
            text=True,
            capture_output=True,
        )
        logger.info("captured monitor list")
    except subprocess.CalledProcessError as e:
        logger.exception(e.stderr)

    monitors = parse_xrandr_output(result.stdout)

    if len(monitors) == 1:
        logger.info("only laptop")
    else:
        logger.info(f"no monitors = {len(monitors)}")

if __name__ == "__main__":
    main()

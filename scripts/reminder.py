import json
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path
from urllib.request import urlopen
from zoneinfo import ZoneInfo

TZ = ZoneInfo("Africa/Cairo")
URL = "https://api.aladhan.com/v1/timingsByCity?city=Cairo&country=Egypt&method=5"
NAMES = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
CACHE = Path.home() / ".cache" / "prayer_times.json"
BEFORE = timedelta(minutes=3)
AFTER = timedelta(minutes=2)
WINDOW = timedelta(seconds=90)


def read_cache():
    try:
        return json.loads(CACHE.read_text())
    except Exception:
        return None


def get_times(today):
    cached = read_cache()
    if cached and cached.get("date") == today:
        return cached["times"]
    try:
        with urlopen(URL, timeout=20) as r:
            timings = json.load(r)["data"]["timings"]
        times = {n: timings[n][:5] for n in NAMES}
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps({"date": today, "times": times}))
        return times
    except Exception:
        return None


def notify(name, t):
    subprocess.run(["notify-send", "-u", "critical", f"{name} in 3 minutes", t])


def lock():
    if subprocess.run(["pgrep", "-x", "hyprlock"], capture_output=True).returncode != 0:
        subprocess.Popen(["hyprlock"])


fired = set()

while True:
    now = datetime.now(TZ)
    today = now.date().isoformat()
    fired = {k for k in fired if k[0] == today}
    times = get_times(today)
    if not times:
        time.sleep(60)
        continue
    for name, t in times.items():
        h, m = map(int, t.split(":"))
        at = now.replace(hour=h, minute=m, second=0, microsecond=0)
        for kind, when in (("notify", at - BEFORE), ("lock", at + AFTER)):
            key = (today, name, kind)
            if key in fired:
                continue
            if when <= now < when + WINDOW:
                fired.add(key)
                if kind == "notify":
                    notify(name, t)
                else:
                    lock()
    time.sleep(15)

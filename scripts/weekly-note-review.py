import os
from datetime import datetime, timedelta
from pathlib import Path
import json
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

REVIEW_FILE = os.path.expanduser("~/MEGA/Obsidian/Weekly Review Tracking.md")

def parse_date(string):
   try:
       return datetime.strptime(string, '%Y-%m-%d')
   except ValueError:
       return None

def check_review_status():
    try:
        with open(REVIEW_FILE, "r") as f:
            lines = f.readlines()

        for line in reversed(lines):
            date = parse_date(line.strip())
            if date and date + timedelta(days=7) >= datetime.now():
                return {"text": "", "class": "normal"}

        return {"text": "󰀦 Do Weekly Review 󰀦 ", "class": "urgent"}

    except Exception as e:
        return {"text": "󰅗 Error", "class": "error", "tooltip": str(e)}


class ReviewHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path == REVIEW_FILE:
            print(json.dumps(check_review_status()), flush=True)


def main():
    if not os.path.exists(REVIEW_FILE):
        print(json.dumps({"text": "󰅗 File not found", "class": "error"}), flush=True)
        return

    print(json.dumps(check_review_status()), flush=True)
    observer = Observer()
    observer.schedule(ReviewHandler(), path=str(Path(REVIEW_FILE).parent))
    observer.start()

    try:
        observer.join()
    except KeyboardInterrupt:
        observer.stop()
        observer.join()


if __name__ == "__main__":
    main()

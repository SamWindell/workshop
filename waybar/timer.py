#!/usr/bin/env python3

import sys
import os
import subprocess
from datetime import datetime, timedelta
import json
import time

HOME = os.environ['HOME']
CONFIG_DIR = f"{HOME}/.config/waybar-timer"
TFILE = f"{CONFIG_DIR}/timer"

# Create config directory if it doesn't exist
os.makedirs(CONFIG_DIR, exist_ok=True)

def notify(message):
    subprocess.run(['notify-send', 'Timer', message])

def check_timer():
    try:
        with open(TFILE, 'r') as f:
            content = f.read().strip()
    except FileNotFoundError:
        with open(TFILE, 'w') as f:
            f.write("READY")
        content = "READY"

    now = datetime.now()
    
    if content == "READY":
        return json.dumps({
            "text": "󰔛",
            "tooltip": "Timer is not active"
        })

    if content == "FINISHED":
        with open(TFILE, 'w') as f:
            f.write("READY")
        notify("Timer expired!")
        return json.dumps({
            "text": "󰔛",
            "tooltip": "Timer is not active"
        })

    try:
        target_datetime_str, title = content.split('|')
        target_datetime = datetime.strptime(target_datetime_str, '%Y-%m-%d %H:%M:%S')

        if target_datetime > now:
            remaining = target_datetime - now
            hours, remainder = divmod(remaining.seconds, 3600)
            minutes, _ = divmod(remainder, 60)
            seconds = remaining.seconds % 60

            remaining_str = ""
            if hours > 0:
                remaining_str += f"{hours}h "
            if minutes > 0:
                remaining_str += f"{minutes}m "
            remaining_str += f"{seconds}s"
            
            target_short = target_datetime_str[:-3]

            return json.dumps({
                "text": f"󰔟 {remaining_str}",
                "class": "active",
                "tooltip": f"{title}\n\n{target_short}"
            })
        else:
            with open(TFILE, 'w') as f:
                f.write("FINISHED")
            return json.dumps({
                "text": "󰔛"
            })
    except ValueError:
        with open(TFILE, 'w') as f:
            f.write("READY")
        return json.dumps({
            "text": "󰔛"
        })

def minute_dialog():
    try:
        result = subprocess.run(
            ['zenity', '--scale', '--title=Set timer', '--text=In x minutes:',
             '--min-value=1', '--max-value=120', '--step=1', '--value=10'],
            capture_output=True, text=True
        )
        
        if result.returncode == 0:
            minutes = int(result.stdout.strip())
            target_time = datetime.now() + timedelta(minutes=minutes)
            with open(TFILE, 'w') as f:
                f.write(f"{target_time.strftime('%Y-%m-%d %H:%M:%S')}|Timer")
    except subprocess.CalledProcessError:
        pass

def pomodoro():
    target_time = datetime.now() + timedelta(minutes=25)
    with open(TFILE, 'w') as f:
        f.write(f"{target_time.strftime('%Y-%m-%d %H:%M:%S')}|Pomodoro")

def stop_timer():
    with open(TFILE, 'w') as f:
        f.write("READY")

def main():
    if len(sys.argv) < 2:
        print("Command required")
        sys.exit(1)

    cmd = sys.argv[1]
    
    if cmd == "check":
        print(check_timer())
    elif cmd == "minute_dialog":
        minute_dialog()
    elif cmd == "pomodoro":
        pomodoro()
    elif cmd == "stop":
        stop_timer()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)

if __name__ == "__main__":
    main()

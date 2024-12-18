#!/usr/bin/env python3
import os
import sys
import time
import subprocess
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List, Union
import platform
import shutil

def hash_string(s: str) -> str:
    return str(hash(s) % 1000000000)

debug_filepath = Path("/tmp/wezterm_setup_debug.txt")
debug_enabled = False

def debug_log(message: str):
    if not debug_enabled:
        return
    with open(debug_filepath, "a") as f:
        f.write(message + "\n")

@dataclass
class Project:
    project_dir: Path



class WeztermSetupBuilder:
    def __init__(self, project: Project):
        self.project = project
        self.class_name = "org.wezfurlong." + hash_string(str(project.project_dir))

    def notify_error(self, message: str):
        subprocess.run(["notify-send", "Script Error", message])

    def run_command(self, cmd: list[str]) -> str:
        try:
            result = subprocess.run(cmd, check=True, text=True, capture_output=True)
            debug_log(f"Command: {' '.join(cmd)}\nOutput: {result.stdout}")
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            error_msg = f"Failed command: {' '.join(cmd)}\nError: {e.stderr}"
            self.notify_error(error_msg)
            sys.exit(1)

    def switch_hyprland_workspace(self, workspace: str):
        if "HYPRLAND_CMD" in os.environ:
            builder.run_command(["hyprctl","dispatch","workspace",workspace])


    def spawn_pane(
        self,
        current_pane_id: Optional[str] = None,
        command: Optional[Union[str, List[str]]] = None,
        create_new_window: bool = False,
    ) -> str:
        cmd = ["wezterm", "cli", "--class", self.class_name, "spawn"]

        if create_new_window:
            cmd.append("--new-window")
        elif current_pane_id:  # Only use parent_id if not creating new window
            cmd.extend(["--pane-id", current_pane_id])

        cmd.extend(["--cwd", str(self.project.project_dir)])

        if command:
            cmd.append("--")
            if isinstance(command, str):
                cmd.extend(command.split())
            else:
                cmd.extend(command)

        return self.run_command(cmd)

    def set_pane_title(self, pane_id: str, title: str):
        self.run_command(
            [
                "wezterm", "cli", "--class", self.class_name,
                "set-tab-title", "--pane-id", pane_id, title,
            ]
        )

    def send_text(self, pane_id: str, text: str):
        self.run_command(
            [
                "wezterm", "cli", "--class", self.class_name,
                "send-text", "--pane-id", pane_id, text,
            ]
        )

    def activate_pane(self, pane_id: str):
        self.run_command(
            [
                "wezterm", "cli", "--class", self.class_name,
                "activate-pane", "--pane-id", pane_id,
            ]
        )

    def start_wezterm(self, command: Optional[Union[str, List[str]]] = None):
        cmd = [
            "wezterm",
            "start",
            "--cwd", str(self.project.project_dir),
            "--class", self.class_name,
        ]
        if command:
            cmd.append("--")
            if isinstance(command, str):
                cmd.extend(command.split())
            else:
                cmd.extend(command)
        try:
            # Use Popen instead of run, with CREATE_NO_WINDOW on Windows
            startupinfo = None
            if sys.platform == "win32":
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                
            subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                startupinfo=startupinfo,
                # Detach the process
                start_new_session=True,
            )
        except Exception as e:
            self.notify_error(f"Failed to start wezterm: {e}")
            sys.exit(1)

    # returns pane ID
    def ensure_wezterm_running(self, command: Optional[Union[str, List[str]]] = None) -> str:
        # wezterm requires a running instance to spawn panes, we need to start it using a different command
        debug_log("Checking if wezterm is running")
        try:
            if ("WEZTERM_UNIX_SOCKET" not in os.environ):
                self.start_wezterm(command)
                time.sleep(0.6)
                return "0" # 0 is the default pane ID
            else:
                return self.spawn_pane(command=command, create_new_window=True)
        except Exception as e:
            debug_log(f"Error: {e}")
            sys.exit(1)

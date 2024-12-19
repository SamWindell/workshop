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
        self.window_pane_id = None

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


    def add_tab(
        self,
        command: Optional[Union[str, List[str]]] = None,
        create_new_window: bool = False,
        title: Optional[str] = None,
    ) -> str:
        create_new_window = False

        # wezterm requires a running instance to spawn panes
        if not self.window_pane_id:
            debug_log("Checking if wezterm is running")
            if "WEZTERM_UNIX_SOCKET" not in os.environ:
                self._start_wezterm(command)
                self.window_pane_id = "0" # in wezterm, 0 is the first pane ID
                time.sleep(0.6) # give wezterm some time to start
                if title:
                    self.set_tab_title(self.window_pane_id, title)
                return self.window_pane_id
            else:
                create_new_window = True

        cmd = ["wezterm", "cli", "--class", self.class_name, "spawn"]

        if create_new_window:
            cmd.append("--new-window")
        else:
            # If we're not creating a new window, we need to let wezterm know which window we're adding a tab to.
            # This is done by specifying the pane-id.
            assert self.window_pane_id
            cmd.extend(["--pane-id", self.window_pane_id])

        cmd.extend(["--cwd", str(self.project.project_dir)])

        if command:
            cmd.append("--")
            if isinstance(command, str):
                cmd.extend(command.split())
            else:
                cmd.extend(command)

        self.window_pane_id = self.run_command(cmd)

        if title:
            self.set_tab_title(self.window_pane_id, title)

        return self.window_pane_id

    def set_tab_title(self, pane_id: str, title: str):
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

    def activate_tab(self, pane_id: str):
        self.run_command(
            [
                "wezterm", "cli", "--class", self.class_name,
                "activate-pane", "--pane-id", pane_id,
            ]
        )

    def _start_wezterm(self, command: Optional[Union[str, List[str]]] = None):
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

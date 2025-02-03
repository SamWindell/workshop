import os
from urllib.parse import unquote
from gi.repository import Nautilus, GObject
from typing import List
import subprocess

# select multiple files and then run a command on them, it asks for the command to run
# and you can use gnu-parallel substitutions in the command, such as {} meaning the file path

label = "Run Command"
id = "runcommand"

class RunCommandExtension(GObject.GObject, Nautilus.MenuProvider):
    def _do_action(self, files: List[Nautilus.FileInfo]) -> None:
        command = subprocess.run(['fuzzel', '--dmenu', '--prompt-only', 'Command: ', '--width', '50'], stdout=subprocess.PIPE)
        command = command.stdout.decode('utf-8').strip()
        if command == "":
            return

        paths = [unquote(f.get_uri()[7:]) for f in files]

        try:
            # Run parallel command with both stdout and stderr captured
            result = subprocess.run(
                ['parallel', command, ':::', *paths],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True  # Automatically decode output to string
            )
            
            # Prepare notification message
            if result.returncode == 0:
                # Success case
                if result.stdout:
                    notification_msg = f"Command completed successfully:\n{result.stdout[:200]}"
                else:
                    notification_msg = "Command completed successfully"
            else:
                # Error case
                error_msg = result.stderr if result.stderr else result.stdout
                notification_msg = f"Command failed (code {result.returncode}):\n{error_msg[:200]}"

            # Send notification
            subprocess.run([
                'notify-send',
                'Parallel Command Result',
                notification_msg
            ])

        except Exception as e:
            # Handle any unexpected errors
            subprocess.run([
                'notify-send',
                'Parallel Command Error',
                f"Failed to execute command: {str(e)}"
            ])


    def menu_activate_cb(
        self,
        menu: Nautilus.MenuItem,
        files: List[Nautilus.FileInfo],
    ) -> None:
        self._do_action(files)

    def get_file_items(
        self,
        files: List[Nautilus.FileInfo],
    ) -> List[Nautilus.MenuItem]:
        if len(files) == 0:
            return []

        for file in files:
            if file.get_uri_scheme() != "file":
                return []

        item = Nautilus.MenuItem(
            name=f"NautilusPython::{id}_file_item",
            label=label,
            tip=label,
        )
        item.connect("activate", self.menu_activate_cb, files)

        return [
            item,
        ]

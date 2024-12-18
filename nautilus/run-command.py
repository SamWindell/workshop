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
        try:
            command = subprocess.run(['fuzzel', '--dmenu', '--prompt-only', 'Command: '], stdout=subprocess.PIPE)
            command = command.stdout.decode('utf-8').strip()
            if command == "":
                return

            paths = [unquote(f.get_uri()[7:]) for f in files]
            subprocess.run([ 'parallel', command, ':::', *paths ])
        except Exception as e:
            os.system(f'notify-send "Run Command Error" "{e}"')

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

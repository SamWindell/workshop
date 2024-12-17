import os
from urllib.parse import unquote
from gi.repository import Nautilus, GObject
from typing import List
import subprocess

# select multiple files and then copy their paths to the clipboard

label = "Copy Paths"
id = "copypaths"

class CopyPathsExtension(GObject.GObject, Nautilus.MenuProvider):
    def _do_action(self, files: List[Nautilus.FileInfo]) -> None:
        # get the paths separated by newlines
        paths = "\n".join([unquote(f.get_uri()[7:]) for f in files])

        process = subprocess.Popen(
            ['wl-copy'],
            stdin=subprocess.PIPE,
            text=True
        )
        process.communicate(input=paths)

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

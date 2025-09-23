#!/usr/bin/env bash

read -r -d '' options << 'EOL'
region
window
EOL

selected=$(echo "$options" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0
option=$(echo "$selected" | awk '{print $1}')

# Create output directory
output_dir="$HOME/Pictures/Screenshots"
mkdir -p "$output_dir"

filename="$(date +'%Y-%m-%d-%H%M%S_screenshot.png')"
full_path="$output_dir/$filename"

hyprctl keyword decoration:dim_inactive false
hyprshot -m "$option" --delay 1 -o "$output_dir" -f "$filename" -- optipng
# hyprctl keyword decoration:dim_inactive true

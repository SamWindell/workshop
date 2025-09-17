#!/usr/bin/env bash

read -r -d '' options << 'EOL'
region
window
EOL

selected=$(echo "$options" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0
option=$(echo "$selected" | awk '{print $1}')

filename="$(date +'%Y-%m-%d-%H%M%S_screenshot.png')"

hyprctl keyword decoration:dim_inactive false
hyprshot -m "$option" --delay 1 --filename "$filename" -- optipng
# hyprctl keyword decoration:dim_inactive true

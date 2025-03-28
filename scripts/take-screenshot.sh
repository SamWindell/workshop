#!/usr/bin/env bash

read -r -d '' options << 'EOL'
region
window
EOL

selected=$(echo "$options" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0
option=$(echo "$selected" | awk '{print $1}')

hyprctl keyword decoration:dim_inactive false
hyprshot -m "$option"
hyprctl keyword decoration:dim_inactive true

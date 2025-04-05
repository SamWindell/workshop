#!/usr/bin/env bash

# Check if wf-recorder is already running
pgrep -x "wf-recorder" && pkill -INT -x wf-recorder && notify-send -h string:wf-recorder:record -t 1000 "Finished Recording" && hyprctl keyword decoration:dim_inactive true && exit 0

read -r -d '' options << 'EOL'
region
window
EOL

selected=$(echo "$options" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0
option=$(echo "$selected" | awk '{print $1}')

hyprctl keyword decoration:dim_inactive false

region=''

if [[ "$option" == "region" ]]; then
    region=$(slurp)
    if [ -z "$region" ]; then
        hyprctl keyword decoration:dim_inactive true
        exit 0
    fi
fi

notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span font='26px'><i><b>3</b></i></span>"

sleep 1

notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span font='26px'><i><b>2</b></i></span>"

sleep 1

notify-send -h string:wf-recorder:record -t 950 "Recording in:" "<span font='26px'><i><b>1</b></i></span>"

sleep 1

filename="$(date +'%Y-%m-%d-%H%M%S_recording')"

if [[ "$option" == "region" ]]; then
    wf-recorder --audio --audio-backend=pipewire -f $HOME/$filename.mp4 -g "$region"
else
    wf-recorder --audio --audio-backend=pipewire -f $HOME/$filename.mp4
fi

hyprctl keyword decoration:dim_inactive true

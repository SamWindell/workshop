#!/usr/bin/env bash
# Audio device configuration
SYSTEM_AUDIO="alsa_output.usb-Yamaha_Corporation_Steinberg_UR22-00.analog-stereo.monitor"
MIC_INPUT="alsa_input.usb-Yamaha_Corporation_Steinberg_UR22-00.analog-stereo"

# Audio quality settings
AUDIO_CODEC="flac"
SAMPLE_RATE="44100"
SAMPLE_FORMAT="s16"

# Function to check if audio devices exist
check_audio_devices() {
   if ! pactl list sources | grep -q "Name: $SYSTEM_AUDIO"; then
       notify-send "Recording Error" "System audio device not found"
       exit 1
   fi
   if ! pactl list sources | grep -q "Name: $MIC_INPUT"; then
       notify-send "Recording Error" "Mic input device not found" 
       exit 1
   fi
}

# Function to setup combined audio (for standard recording)
setup_combined_audio() {
    pactl load-module module-null-sink sink_name=Combined >/dev/null 2>&1
    pactl load-module module-loopback sink=Combined source="$SYSTEM_AUDIO" >/dev/null 2>&1
    pactl load-module module-loopback sink=Combined source="$MIC_INPUT" channel_map=mono sink_input_properties=media.role=production >/dev/null 2>&1
}

# Function to cleanup audio modules
cleanup_audio() {
   pactl unload-module module-loopback >/dev/null 2>&1
   pactl unload-module module-null-sink >/dev/null 2>&1
}

# Global variable to store mic recording PID
MIC_RECORD_PID=""

# Function to start wf-recorder with audio quality settings
start_wf_recorder() {
    local audio_source="$1"
    local output_file="$2"
    local region="$3"
    
    local wf_args=(
        --audio="$audio_source"
        -C "$AUDIO_CODEC"
        -p "sample_rate=$SAMPLE_RATE"
        -p "sample_fmt=$SAMPLE_FORMAT"
        -f "$output_file"
    )
    
    if [[ -n "$region" ]]; then
        wf_args+=(-g "$region")
    fi
    
    wf-recorder "${wf_args[@]}"
}

# Cleanup function for script exit
cleanup_and_exit() {
   # Kill mic recording if it's running
   if [[ -n "$MIC_RECORD_PID" ]]; then
       kill -INT "$MIC_RECORD_PID" 2>/dev/null
   fi
   cleanup_audio
   exit 0
}

# Function to get window geometry
get_window_geometry() {
    local monitors=$(hyprctl -j monitors)
    local clients=$(hyprctl -j clients | jq -r '[.[] | select(.workspace.id | contains('$(echo $monitors | jq -r 'map(.activeWorkspace.id) | join(",")')'))]')
    local boxes=$(echo $clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"' | cut -f1,2 -d' ')
    slurp -r <<< "$boxes"
}

# Function for separate track recording
record_with_separate_tracks() {
    local filename="$1"
    local region="$2"
    
    # Start mic recording in background with high quality settings
    parecord --device="$MIC_INPUT" --file-format=flac --rate="$SAMPLE_RATE" --format="${SAMPLE_FORMAT}le" --channels=1 "${filename}_mic.flac" &
    MIC_RECORD_PID=$!
    
    # Start video recording with high quality audio
    start_wf_recorder "$SYSTEM_AUDIO" "${filename}.mp4" "$region"
}

# Function for standard combined recording
record_with_combined_audio() {
    local filename="$1"
    local region="$2"
    
    setup_combined_audio
    
    # Start video recording with high quality combined audio
    start_wf_recorder "Combined.monitor" "${filename}.mp4" "$region"
}

# Set trap for cleanup on script exit
trap cleanup_and_exit EXIT INT TERM

# Check if wf-recorder is already running
pgrep -x "wf-recorder" && pkill -INT -x wf-recorder && notify-send -h string:wf-recorder:record -t 1000 "Finished Recording" && exit 0

# Recording mode selection
read -r -d '' mode_options << 'EOL'
🎥 Standard (mixed audio)
🎬 Separate tracks (system + mic)
EOL

selected_mode=$(echo "$mode_options" | fuzzel --dmenu)
[ -z "$selected_mode" ] && exit 0

# Extract mode from selection
if [[ "$selected_mode" == *"Standard"* ]]; then
    recording_mode="standard"
elif [[ "$selected_mode" == *"Separate"* ]]; then
    recording_mode="separate"
else
    exit 0
fi

# Region selection (same as before)
read -r -d '' options << 'EOL'
📍 Region
🪟 Window
🖥️ Output
EOL

selected=$(echo "$options" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0

option=$(echo "$selected" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
region=''

if [[ "$option" == "region" ]]; then
   region=$(slurp)
   if [ -z "$region" ]; then
       exit 0
   fi
elif [[ "$option" == "window" ]]; then
   region=$(get_window_geometry)
   if [ -z "$region" ]; then
       exit 0
   fi
fi

# Check audio devices
check_audio_devices

# Countdown
notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span font='26px'><i><b>3</b></i></span>"
sleep 1
notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span font='26px'><i><b>2</b></i></span>"
sleep 1
notify-send -h string:wf-recorder:record -t 950 "Recording in:" "<span font='26px'><i><b>1</b></i></span>"
sleep 0.5
pkill -x play
sleep 0.5

# Create output directory
output_dir="$HOME/Videos/Screen Recordings"
mkdir -p "$output_dir"

# Generate filename
filename="$(date +'%Y-%m-%d-%H%M%S_recording')"
full_path="$output_dir/$filename"

# Record based on selected mode
if [[ "$recording_mode" == "separate" ]]; then
    record_with_separate_tracks "$full_path" "$region"
    notify-send -h string:wf-recorder:record "Recording finished!" "Video: ${full_path}.mp4\nMic: ${full_path}_mic.flac"
else
    record_with_combined_audio "$full_path" "$region"
    notify-send -h string:wf-recorder:record "Recording finished!" "File: ${full_path}.mp4"
fi

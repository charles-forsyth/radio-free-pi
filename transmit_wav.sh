#!/bin/bash

# --- Configuration ---
DEFAULT_PI="F00D"
CONFIG_FILE="$HOME/.norse_radio.conf"
TEMP_WAV="/tmp/broadcast_temp.wav"
child_pid=0

# --- Functions ---

cleanup() {
    echo -e "\nCaught Ctrl+C, the spirits are displeased. Halting the ritual."
    if [ "$child_pid" -ne 0 ] && ps -p $child_pid > /dev/null; then
        echo "Stopping the incantation (PID $child_pid)..."
        sudo kill -SIGTERM -- -$child_pid
    fi
    if pgrep -f "pifmrds" > /dev/null; then
        echo "Ensuring the ether is clear of pifmrds..."
        sudo pkill -f "pifmrds"
    fi
    exit 1
}

transmit_file() {
    local original_path=$1
    local freq=$2
    local pi=$3
    local ps=$4
    local rt=$5
    local is_playlist=${6:-false}

    local file_to_transmit=$original_path
    local extension="${original_path##*.}"

    if [ ! -f "$original_path" ]; then
        echo "The scroll '$original_path' cannot be found in this realm."
        return 1
    fi

    if [ "$extension" != "wav" ]; then
        echo "Transmuting '$original_path' into a temporary WAV scroll..."
        ffmpeg -i "$original_path" -acodec pcm_s16le -ac 1 -ar 22050 "$TEMP_WAV" -y >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "The transmutation failed. The scroll may be cursed."
            return 1
        fi
        file_to_transmit=$TEMP_WAV
    fi

    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$original_path" | awk '{print int($1) + ($1 > int($1))}')
    
    if [ -z "$duration" ]; then
        echo "The duration of the chant in '$original_path' is unknown. Skipping."
        rm -f "$TEMP_WAV"
        return 1
    fi

    echo "Broadcasting '$ps' on $freq MHz: $rt"
    if [ "$is_playlist" = true ]; then
        echo "Chanting from '$original_path' for ${duration}s. Press 'n' to skip, or Ctrl+C to halt."
    else
        echo "Chanting from '$original_path' for ${duration}s. Press Ctrl+C to halt the ritual."
    fi
    
    sudo timeout "${duration}s" ./repos/rpitx/pifmrds -audio "$file_to_transmit" -freq "$freq" -pi "$pi" -ps "$ps" -rt "$rt" &
    child_pid=$!

    if [ "$is_playlist" = true ]; then
        while ps -p $child_pid > /dev/null; do
            read -t 0.5 -n 1 -s key
            if [[ "$key" == "n" || "$key" == "N" ]]; then
                echo -e "\nSkipping to the next chant..."
                sudo pkill -SIGKILL -f "pifmrds -audio" >/dev/null 2>&1
                break
            fi
        done
    fi

    wait $child_pid >/dev/null 2>&1
    child_pid=0
    rm -f "$TEMP_WAV"
}

# --- Main Script ---
trap cleanup SIGINT

echo "--- The Druid's Broadcasting Circle ---"

SETTINGS_LOADED=false
if [ -f "$CONFIG_FILE" ]; then
    read -p "A runestone was found. Use the saved settings? [Y/n]: " use_saved
    if [[ "$use_saved" == "" || "$use_saved" == "y" || "$use_saved" == "Y" ]]; then
        echo "Loading settings from the runestone..."
        source "$CONFIG_FILE"
        SETTINGS_LOADED=true
    fi
fi

if [ "$SETTINGS_LOADED" = false ]; then
    echo "Prepare the ritual of transmission."
    echo "Choose the frequency for the broadcast:"
    echo "  1) GMRS Ch. 16 (462.575 MHz) - Default"
    echo "  2) GMRS Ch. 19 (462.650 MHz)"
    echo "  3) GMRS Ch. 4 (462.6375 MHz)"
    echo "  4) Common FM (92.3 MHz)"
    echo "  5) Common FM (100.7 MHz)"
    echo "  6) MURS Ch. 1 (151.820 MHz) - For the adventurous"
    echo "  7) Custom Frequency"
    read -p "Choose your path [1]: " freq_choice

    case ${freq_choice:-1} in
        1) FREQ="462.575" ;;
        2) FREQ="462.650" ;;
        3) FREQ="462.6375" ;;
        4) FREQ="92.3" ;;
        5) FREQ="100.7" ;;
        6) FREQ="151.820" ;;
        7) read -p "Enter custom frequency in MHz: " FREQ ;;
        *) echo "Invalid choice. Using default 462.575 MHz."; FREQ="462.575" ;;
    esac

    read -p "Enter the station's runic code (PI) [${DEFAULT_PI}]: " pi
    PI="${pi:-$DEFAULT_PI}"

    read -p "Enter the station's name (8 chars max, e.g., 'Yggdrasil'): " ps
    PS_NAME="${ps:-Yggdrasil}"

    read -p "Enter the RadioText (64 chars max, e.g., 'The whispers of the old gods'): " rt
    RT_TEXT="${rt:-The whispers of the old gods}"

    read -p "Carve these settings into a runestone for future use? [y/N]: " save_settings
    if [[ "$save_settings" == "y" || "$save_settings" == "Y" ]]; then
        echo "Saving settings to $CONFIG_FILE..."
        echo "FREQ=\"$FREQ\"" > "$CONFIG_FILE"
        echo "PI=\"$PI\"" >> "$CONFIG_FILE"
        echo "PS_NAME=\"$PS_NAME\"" >> "$CONFIG_FILE"
        echo "RT_TEXT=\"$RT_TEXT\"" >> "$CONFIG_FILE"
    fi
fi

while true; do
    echo "---------------------------------------"
    echo "1. Transmit a single scroll (audio file)"
    echo "2. Transmit all scrolls in a sacred grove (directory)"
    echo "3. Depart the circle (Exit)"
    read -p "Choose your ritual [1-3, default 2]: " choice
    echo "---------------------------------------"

    case ${choice:-2} in
        1)
            read -p "Enter the path to the sacred scroll: " audio_file
            transmit_file "$audio_file" "$FREQ" "$PI" "$PS_NAME" "$RT_TEXT" false
            ;;
        2)
            read -p "Enter the path to the sacred grove [.]: " audio_dir
            AUDIO_DIR="${audio_dir:-.}"

            if [ ! -d "$AUDIO_DIR" ]; then
                echo "The grove at '$AUDIO_DIR' does not exist."
                continue
            fi

            files=()
            while IFS= read -r -d $'\0'; do
                files+=("$REPLY")
            done < <(find "$AUDIO_DIR" -maxdepth 1 -type f \( -iname "*.wav" -o -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" \) -print0)

            if [ ${#files[@]} -eq 0 ]; then
                echo "No suitable scrolls found in '$AUDIO_DIR'."
                continue
            fi
            
            echo "Found ${#files[@]} scrolls to broadcast."
            for x in "${files[@]}"; do
                transmit_file "$x" "$FREQ" "$PI" "$PS_NAME" "$RT_TEXT" true
            done
            ;;
        3)
            echo "The ritual is complete. The circle is now open."
            break
            ;;
        *)
            echo "An unwise choice. The spirits are confused. Please choose again."
            ;;
    esac
done

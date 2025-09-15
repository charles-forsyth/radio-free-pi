# The Druid's Broadcasting Circle (`transmit_wav.sh`)

This document serves as a guide to using the `transmit_wav.sh` script, a tool for broadcasting audio scrolls (audio files) through the ether using a Raspberry Pi.

## Purpose

The script allows a user to transmit audio files over a specified FM/GMRS frequency. It provides a menu-driven interface to select audio sources, configure the broadcast with custom station identification (RDS), and save settings for future use, all wrapped in a Norse Druid Wizard theme. It supports transcoding from various audio formats like `.mp3`, `.flac`, and `.ogg` into the required `.wav` format.

## File Location

The `transmit_wav.sh` script should be placed in the home directory of your "core" machine (e.g., `/home/pi/transmit_wav.sh`).

The `pifmrds` executable, which is part of the `rpitx` repository, is expected to be located at `./repos/rpitx/pifmrds` relative to where you run the script.

## Dependencies

Before performing the ritual, ensure the following are installed and accessible on your system:

*   **`ffmpeg` / `ffprobe`**: A multimedia framework used to determine the duration of the audio scrolls and to transcode them into the `.wav` format.
    *   *Source Repository*: [https://github.com/FFmpeg/FFmpeg](https://github.com/FFmpeg/FFmpeg)
*   **`pifmrds`**: The core incantation for FM transmission, part of the `rpitx` project.
    *   *Source Repository*: [https://github.com/F5OEO/rpitx](https://github.com/F5OEO/rpitx)

## How to Use

1.  **Make the Script Executable**: If you haven't already, make the script executable:
    ```bash
    chmod +x transmit_wav.sh
    ```

2.  **Run the Script**: Execute the script from your home directory:
    ```bash
    ./transmit_wav.sh
    ```

3.  **Follow the Prompts**: The script will guide you through a series of prompts:
    *   **Frequency**: Choose from a list of preset GMRS and FM frequencies or enter a custom one.
    *   **Runic Code (PI)**: The Program Identification code for your station (a 4-digit hex code).
    *   **Station Name (PS)**: An 8-character name for your station (e.g., `Yggdrasil`).
    *   **RadioText (RT)**: A 64-character message for your broadcast.
    *   **Save Settings**: Choose whether to save the current configuration to `~/.norse_radio.conf`.
    *   **Ritual Choice**: Choose to transmit a single audio scroll or all scrolls in a directory (playlist mode).

## Broadcast Controls

*   **Stopping the Ritual (Ctrl+C)**: To stop the broadcast at any time, press `Ctrl+C`. The script includes a cleanup function to gracefully halt the transmission.
*   **Skipping Tracks**: In playlist mode, press `n` to skip to the next audio file.

## The Ritual Options (RDS Features)

The script allows you to imbue your broadcast with magical properties (RDS features):

*   **Runic Code (PI)**: `-pi` - A unique hexadecimal code for your station (e.g., `F00D`).
*   **Station Name (PS)**: `-ps` - An 8-character name that appears on compatible radios.
*   **RadioText (RT)**: `-rt` - A longer, 64-character message to accompany your broadcast.

## Manual Command Example

For a non-interactive, scripted approach, you can use a command like the following to play all `.wav` files in a directory:

```bash
for x in *.wav; do
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$x" | awk '{print int($1) + ($1 > int($1))}');
  echo "Processing $x with a timeout of ${duration}s";
  sudo timeout "${duration}s" ./repos/rpitx/pifmrds -audio "$x" -freq 462.575;
done
```

Another example for a single file on a different frequency:
```bash
cd /home/pi/repos/rpitx && sudo ./pifmrds -freq 17.2 -audio /home/pi/broadcasts/Tropical_Island_relaxing_guitar_20250711_093907.wav"
```

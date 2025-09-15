## Project Overview

This directory contains `radio-free-pi`, a project designed to turn a Raspberry Pi into a versatile FM and GMRS radio transmitter. The core of the project is `transmit_wav.sh`, a user-friendly shell script that provides a menu-driven interface for broadcasting audio files.

The system is built upon two key external dependencies:
1.  **`rpitx`**: A project for general radio transmission from a Raspberry Pi. This project specifically uses the `pifmrds` executable for FM transmission with RDS capabilities. The source code for `rpitx` is located in the `repos/rpitx` directory.
2.  **`ffmpeg`**: A comprehensive multimedia framework. Its `ffprobe` tool is used to determine audio file durations for seamless playback, and `ffmpeg` itself is used to transcode various audio formats (like `.mp3`, `.flac`, `.ogg`) into the `.wav` format required by `pifmrds`.

The project has a distinct "Norse Druid Wizard" theme in its user interface, referring to audio files as "scrolls" and directories as "sacred groves."

## Running the Project

There is no build process required. The main script can be run directly.

### Interactive Mode

The primary way to use the system is through the interactive script.

1.  **Make the script executable:**
    ```bash
    chmod +x transmit_wav.sh
    ```

2.  **Run the script:**
    ```bash
    ./transmit_wav.sh
    ```

The script will guide you through selecting a frequency, setting RDS information (station name, etc.), and choosing audio files to broadcast, either individually or as a playlist from a directory. It can also save your settings to `~/.norse_radio.conf` for future sessions.

### Manual (Non-Interactive) Mode

For automated or scripted broadcasting, you can use a one-line command. The following command will find all `.wav` files in the current directory, determine their duration, and broadcast them sequentially on the GMRS frequency 462.575 MHz.

```bash
for x in *.wav; do
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$x" | awk '{print int($1) + ($1 > int($1))}');
  echo "Processing $x with a timeout of ${duration}s";
  sudo timeout "${duration}s" ./repos/rpitx/pifmrds -audio "$x" -freq 462.575;
done
```

## Key Files

*   `transmit_wav.sh`: The main interactive shell script for controlling the radio broadcast.
*   `README.md`: The primary documentation for the project.
*   `repos/rpitx/`: A local copy of the `rpitx` repository, which contains the `pifmrds` binary used for transmission.
*   `radio-station-command.txt`: Contains the one-line command for manual, non-interactive broadcasting.
*   `radio.txt`: Contains the string `wsab613`, likely a GMRS call sign or station identifier.

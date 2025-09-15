# The Druid's Broadcasting Circle (`transmit_wav.sh`)

This document serves as a guide to using the `transmit_wav.sh` script, a tool for broadcasting audio scrolls (`.wav` files) through the ether using a Raspberry Pi and the `pifmrds` incantation.

## Purpose

The script allows a user to transmit audio files over a specified FM frequency. It provides a menu-driven interface to select audio sources and configure the broadcast with custom station identification, all wrapped in a Norse Druid Wizard theme.

## File Location

The `transmit_wav.sh` script should be placed in the home directory of your "core" machine (e.g., `/home/pi/transmit_wav.sh`).

The `pifmrds` executable, which is part of the `rpitx` repository, is expected to be located at `./repos/rpitx/pifmrds` relative to where you run the script.

## Dependencies

Before performing the ritual, ensure the following are installed and accessible on your system:

*   **`ffprobe`**: Part of the `ffmpeg` suite, used to determine the duration of the audio scrolls.
*   **`pifmrds`**: The core incantation for FM transmission.

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
    *   **Frequency**: The FM frequency to broadcast on (e.g., `462.575`).
    *   **Runic Code (PI)**: The Program Identification code for your station (a 4-digit hex code).
    *   **Station Name (PS)**: An 8-character name for your station (e.g., `Yggdrasil`).
    *   **RadioText (RT)**: A 64-character message for your broadcast.
    *   **Ritual Choice**: Choose to transmit a single audio scroll or all scrolls in a directory.

## The Ritual Options (RDS Features)

The script allows you to imbue your broadcast with magical properties (RDS features):

*   **Runic Code (PI)**: `-pi` - A unique hexadecimal code for your station (e.g., `F00D`).
*   **Station Name (PS)**: `-ps` - An 8-character name that appears on compatible radios.
*   **RadioText (RT)**: `-rt` - A longer, 64-character message to accompany your broadcast.

## Stopping the Ritual (Ctrl+C)

To stop the broadcast at any time, press `Ctrl+C`. The script includes a cleanup function to gracefully halt the transmission and clear the ether of any lingering magical energies.

#!/usr/bin/env bash

set -e

#CONFIG TO ADAPT
anime="Jujutsu Kaisen: Shimetsu Kaiyuu - Zenpen"

episodes=7-12

folder_path="Jujutsu_Kaisen"
DOWNLOAD_DIR="/srv/media/anime/${folder_path}"


mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"


# Disable player requirement
export ANI_CLI_PLAYER=true


ani-cli -d "$anime" -e "$episodes"

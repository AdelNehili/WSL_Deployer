#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"


worlds=()

#_____________________________________________________Tools_____________________________________________________
usage() {
  echo "Usage: $0 up"
  echo "Usage: $0 down"
  echo "_____________________"
  echo "Usage: $0 save"
  echo "Usage: $0 reset"
  echo "Usage: $0 remove"
  
  exit 1
}

scan_worlds() {
  echo "Scanning for Minecraft worlds..."

  for dir in "$BASE_DIR"/*; do
    if [[ -d "$dir/minecraft-data" ]]; then
      worlds+=("$(basename "$dir")")
    fi
  done

  if [[ ${#worlds[@]} -eq 0 ]]; then
    echo "No worlds found."
    exit 1
  fi
}

display_worlds() {
  echo "Available worlds with minecraft-data folder:"
  for i in "${!worlds[@]}"; do
    printf "%d) %s\n" "$((i+1))" "${worlds[$i]}"
  done
}

choose_world() {
  echo
  read -rp "Select a world: " choice

  index=$((choice-1))

  if [[ -z "${worlds[$index]}" ]]; then
    echo "Invalid selection."
    exit 1
  fi

  WORLD="${worlds[$index]}"
  WORLD_PATH="$BASE_DIR/$WORLD"
}


#_____________________________________________________Actions_____________________________________________________
down_world() {
  echo
  if docker compose -f "$WORLD_PATH/docker-compose.yml" ps | grep -q "Up"; then
    echo "World '$WORLD' is already running."
    docker compose -f "$WORLD_PATH/docker-compose.yml" down
    
    echo "Closing server..."
    echo "World '$WORLD' is now shutting down."
    return
  fi
  echo "World Down went wrong..."


}

run_world() {
  echo
  if docker compose -f "$WORLD_PATH/docker-compose.yml" ps | grep -q "Up"; then
    echo "World '$WORLD' is already running."
    return
  fi

  echo "Starting server..."
  docker compose -f "$WORLD_PATH/docker-compose.yml" up -d

  echo "World '$WORLD' is now running."
}

reset_world() {
  echo
  echo "Stopping server..."
  docker compose -f "$WORLD_PATH/docker-compose.yml" down

  echo "Deleting world data..."
  rm -rf "$WORLD_PATH/minecraft-data/world"*

  echo "Starting server..."
  docker compose -f "$WORLD_PATH/docker-compose.yml" up -d

  echo "World '$WORLD' has been reset."
}

remove_world() {
  echo
  echo "Stopping server..."
  docker compose -f "$WORLD_PATH/docker-compose.yml" down

  echo "Deleting world"
  rm -rf "$WORLD_PATH/minecraft-data"*

  echo "World '$WORLD' has been removed."
}

save_world() {
  echo

  TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  SAVE_PATH="$BASE_DIR/Archives/world_${WORLD}_${TIMESTAMP}"

  mkdir -p "$SAVE_PATH"

  echo "Stopping server..."
  docker compose -f "$WORLD_PATH/docker-compose.yml" down

  echo "Creating Minecraft-compatible save..."

  # Copy overworld contents
  cp -a "$WORLD_PATH/minecraft-data/world/"* "$SAVE_PATH/"

  # Merge Nether
  if [[ -d "$WORLD_PATH/minecraft-data/world_nether/DIM-1" ]]; then
    mkdir -p "$SAVE_PATH/DIM-1"
    cp -a "$WORLD_PATH/minecraft-data/world_nether/DIM-1/"* "$SAVE_PATH/DIM-1/"
  fi

  # Merge End
  if [[ -d "$WORLD_PATH/minecraft-data/world_the_end/DIM1" ]]; then
    mkdir -p "$SAVE_PATH/DIM1"
    cp -a "$WORLD_PATH/minecraft-data/world_the_end/DIM1/"* "$SAVE_PATH/DIM1/"
  fi

  echo "Save created:"
  echo "$SAVE_PATH"
}


#_____________________________________________________Main_____________________________________________________
main() {
  case "$1" in
    reset)
      scan_worlds
      display_worlds
      choose_world
      reset_world
      ;;

    remove)
      scan_worlds
      display_worlds
      choose_world

      echo
      read -rp "Type the world name ('$WORLD') to confirm HARD remove: " confirm

      if [[ "$confirm" != "$WORLD" ]]; then
        echo "Confirmation failed. Aborting."
        exit 1
      fi
      remove_world
      ;;
      
    save)
      scan_worlds
      display_worlds
      choose_world
      save_world
      ;;
    up)
      scan_worlds
      display_worlds
      choose_world
      run_world
      ;;
    down)
      scan_worlds
      display_worlds
      choose_world
      down_world
      ;;
    
    *)
      usage
      ;;
  esac
}

main "$@"
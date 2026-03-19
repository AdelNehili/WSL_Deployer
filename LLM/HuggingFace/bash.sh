#!/usr/bin/env bash

set -e

# -----------------------------
# Config
# -----------------------------
MODEL_REPO="bartowski/Phi-3.5-mini-instruct_Uncensored-GGUF"
MODEL_FILE="Phi-3.5-mini-instruct_Uncensored-Q4_K_M.gguf"
TARGET_DIR="./models"

# -----------------------------
# Check dependencies
# -----------------------------
echo "Checking dependencies..."

if ! command -v huggingface-cli &> /dev/null; then
    echo "huggingface-cli not found. Installing..."
    pip install -U "huggingface_hub[cli]"
fi

# -----------------------------
# Create model directory
# -----------------------------
mkdir -p "$TARGET_DIR"

# -----------------------------
# Download model
# -----------------------------
echo "Downloading model: $MODEL_FILE"
huggingface-cli download "$MODEL_REPO" \
    --include "$MODEL_FILE" \
    --local-dir "$TARGET_DIR" \
    --local-dir-use-symlinks False

# -----------------------------
# Done
# -----------------------------
echo "Model downloaded to: $TARGET_DIR/$MODEL_FILE"
#!/bin/bash

# run_conversion.sh
# This script activates the Python virtual environment (if it exists)
# and executes the mp4_to_apng.py Python script.

# --- Configuration ---
# Name of the Python virtual environment directory
VENV_DIR="venv"
# Name of the Python script to execute
PYTHON_SCRIPT="mp4_to_apng.py"

# --- Safety Checks ---
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail # Pipelines return the exit status of the last command to exit with a non-zero status

# --- Logging ---
log() {
  echo "[RUN] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# --- Main Execution ---

log "Starting conversion process..."

# Check if the Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    log "ERROR: Python script '$PYTHON_SCRIPT' not found in the current directory."
    exit 1
fi

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    log "ERROR: Python virtual environment directory '$VENV_DIR' not found."
    log "Please run './setup_env.sh' first to create the environment."
    exit 1
fi

# Activate the virtual environment
# The source command executes the activate script in the current shell context
log "Activating Python virtual environment from '$VENV_DIR'..."
source "$VENV_DIR/bin/activate" || { log "ERROR: Failed to activate virtual environment."; exit 1; }

log "Virtual environment activated."
log "Running Python conversion script: $PYTHON_SCRIPT"
echo "--------------------------------------------------" # Separator for script output

# Execute the Python script
# Use python3 explicitly if needed, but 'python' should work within the activated venv
python "$PYTHON_SCRIPT"

# Capture the exit code of the Python script
PYTHON_EXIT_CODE=$?
echo "--------------------------------------------------" # Separator for script output
log "Python script finished with exit code: $PYTHON_EXIT_CODE"

# Deactivate the virtual environment (good practice, though the script exits anyway)
log "Deactivating virtual environment..."
deactivate

if [ $PYTHON_EXIT_CODE -ne 0 ]; then
    log "ERROR: Python script reported errors. Check the output above and the conversion.log file."
    exit $PYTHON_EXIT_CODE
else
    log "Conversion process completed successfully."
    exit 0
fi

#!/bin/bash

# initialize_project.sh
# This script sets up the basic directory structure and files for the MP4 to APNG conversion project.

# --- Configuration ---
# Set the base directory for the project. By default, it's the current directory.
PROJECT_DIR="."
# Name of the directory to hold input MP4 files
MP4_DIR="mp4"
# Name of the directory to hold output APNG files
EXPORT_DIR="export"
# Name of the README file
README_FILE="README.md"

# --- Safety Checks ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipelines return the exit status of the last command to exit with a non-zero status,
# or zero if all commands exit successfully.
set -o pipefail

# --- Logging ---
# Function to log messages to standard output
log() {
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting project initialization..."

# --- Directory Creation ---
# Create the main project directories if they don't exist.
# The -p flag ensures that parent directories are created if needed,
# and it doesn't error if the directory already exists.

log "Creating directory: ${PROJECT_DIR}/${MP4_DIR}"
mkdir -p "${PROJECT_DIR}/${MP4_DIR}"

log "Creating directory: ${PROJECT_DIR}/${EXPORT_DIR}"
mkdir -p "${PROJECT_DIR}/${EXPORT_DIR}"

# --- README File Creation ---
# Create a basic README.md file if it doesn't exist.
README_PATH="${PROJECT_DIR}/${README_FILE}"
if [ ! -f "$README_PATH" ]; then
  log "Creating ${README_FILE}..."
  cat > "$README_PATH" << EOF
# MP4 to APNG Conversion Project

This project contains scripts to convert MP4 video files into animated PNG (APNG) files.

## Structure

* \`mp4/\`: Place your input MP4 files in this directory.
* \`export/\`: Converted APNG files will be saved here.
* \`mp4_to_apng.py\`: The Python script that performs the conversion using ffmpeg.
* \`initialize_project.sh\`: This script (used to set up this structure).
* \`setup_env.sh\`: Installs dependencies and sets up the Python virtual environment.
* \`run_conversion.sh\`: Runs the conversion process.
* \`cleanup.sh\`: Uninstalls dependencies installed by setup_env.sh and removes the virtual environment.
* \`INSTRUCTIONS.md\`: Detailed usage instructions.

## Usage

See \`INSTRUCTIONS.md\` for step-by-step guidance.
EOF
else
  log "${README_FILE} already exists, skipping creation."
fi

# --- Git Initialization ---
# Check if this directory is already a git repository
if [ ! -d "${PROJECT_DIR}/.git" ]; then
    log "Initializing Git repository..."
    # Initialize git repository
    git init
    log "Git repository initialized."

    # Create a .gitignore file
    GITIGNORE_PATH="${PROJECT_DIR}/.gitignore"
    log "Creating .gitignore file..."
    cat > "$GITIGNORE_PATH" << EOF
# Python virtual environment
venv/
__pycache__/
*.pyc

# Exported files (often large)
export/*
!export/.gitkeep

# MP4 files (often large)
mp4/*
!mp4/.gitkeep

# Log files
*.log

# Dependency tracking file
.installed_packages
EOF
    log ".gitignore file created."

    # Add placeholder files to keep directories in git if they are empty
    touch "${PROJECT_DIR}/${MP4_DIR}/.gitkeep"
    touch "${PROJECT_DIR}/${EXPORT_DIR}/.gitkeep"

    # Add files and commit
    log "Adding files to Git and making initial commit..."
    git add "$README_PATH" "$GITIGNORE_PATH" "${PROJECT_DIR}/${MP4_DIR}/.gitkeep" "${PROJECT_DIR}/${EXPORT_DIR}/.gitkeep"
    # Add the scripts themselves if they exist in the current directory
    # This assumes you save the scripts in the project root
    git add *.sh *.py INSTRUCTIONS.md || true # Allow failure if files don't exist yet
    git commit -m "Initial project structure setup"
    log "Initial commit created."

else
    log "Directory is already a Git repository, skipping initialization."
fi


log "Project initialization completed successfully."
echo "--------------------------------------------------"
echo "Next steps:"
echo "1. Place your MP4 files into the '${MP4_DIR}' directory."
echo "2. Run './setup_env.sh' to install dependencies."
echo "3. Run './run_conversion.sh' to perform the conversion."
echo "--------------------------------------------------"

exit 0

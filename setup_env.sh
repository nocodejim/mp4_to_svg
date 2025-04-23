#!/bin/bash

# setup_env.sh
# This script checks for and installs necessary dependencies (ffmpeg, python3, pip)
# and sets up a Python virtual environment for the MP4 to APNG conversion project.

# --- Configuration ---
# Name of the Python virtual environment directory
VENV_DIR="venv"
# File to track packages installed by this script
INSTALLED_PACKAGES_FILE=".installed_packages"
# List of required apt packages
REQUIRED_PACKAGES=("ffmpeg" "python3" "python3-pip" "python3-venv")

# --- Safety Checks ---
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail # Pipelines return the exit status of the last command to exit with a non-zero status

# --- Logging ---
log() {
  echo "[SETUP] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# --- Functions ---

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check if an apt package is installed
package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

# --- Main Execution ---

log "Starting environment setup..."

# Clear previous installation tracking file if it exists
if [ -f "$INSTALLED_PACKAGES_FILE" ]; then
    log "Removing previous package installation tracking file."
    rm "$INSTALLED_PACKAGES_FILE"
fi
touch "$INSTALLED_PACKAGES_FILE" # Create an empty tracking file

# --- Dependency Check and Installation ---
NEEDS_UPDATE=false
PACKAGES_TO_INSTALL=()

log "Checking required system packages..."
for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! package_installed "$pkg"; then
    log "Package '$pkg' is not installed."
    PACKAGES_TO_INSTALL+=("$pkg")
    NEEDS_UPDATE=true
  else
    log "Package '$pkg' is already installed."
  fi
done

# Install missing packages if any
if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
  log "Attempting to install missing packages: ${PACKAGES_TO_INSTALL[*]}"
  log "This may require sudo privileges."

  # Update package lists first, only if needed
  if [ "$NEEDS_UPDATE" = true ]; then
      log "Running apt update..."
      sudo apt update || { log "ERROR: Failed to run apt update. Please check permissions and internet connection."; exit 1; }
  fi

  # Install the packages
  sudo apt install -y "${PACKAGES_TO_INSTALL[@]}" || { log "ERROR: Failed to install packages. Please check apt logs."; exit 1; }

  # Verify installation and record installed packages
  log "Verifying installation..."
  for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
      if package_installed "$pkg"; then
          log "Successfully installed '$pkg'."
          # Record the package name for cleanup purposes
          echo "$pkg" >> "$INSTALLED_PACKAGES_FILE"
      else
          log "ERROR: Failed to verify installation of '$pkg'. Please check apt logs."
          # Consider exiting here depending on how critical the package is
          # exit 1;
      fi
  done
else
  log "All required system packages are already installed."
fi

# --- Python Virtual Environment Setup ---
log "Checking for Python 3..."
if ! command_exists python3; then
  log "ERROR: python3 command not found, even after attempting installation. Please install Python 3 manually."
  exit 1
fi

log "Checking for pip3..."
# Sometimes pip is installed as pip3
if ! command_exists pip3 && ! command_exists pip; then
    log "ERROR: pip command not found, even after attempting installation. Please install Python 3 pip manually."
    exit 1
fi

# Check if the virtual environment directory already exists
if [ -d "$VENV_DIR" ]; then
  log "Python virtual environment '$VENV_DIR' already exists. Skipping creation."
  # Optional: Add logic here to check if it's functional or needs update
else
  log "Creating Python virtual environment in '$VENV_DIR'..."
  # Use the python3 -m venv command which is standard
  python3 -m venv "$VENV_DIR" || { log "ERROR: Failed to create Python virtual environment."; exit 1; }
  log "Virtual environment created successfully."
fi

# --- Final Checks ---
log "Verifying ffmpeg command..."
if ! command_exists ffmpeg; then
    log "ERROR: ffmpeg command not found, even after attempting installation. Please install ffmpeg manually."
    exit 1
fi
log "ffmpeg is available."

log "Environment setup completed successfully."
echo "--------------------------------------------------"
echo "Virtual environment is ready in the '$VENV_DIR' directory."
echo "Packages installed by this script are tracked in '$INSTALLED_PACKAGES_FILE'."
echo "You can now run the conversion using './run_conversion.sh'."
echo "--------------------------------------------------"

exit 0

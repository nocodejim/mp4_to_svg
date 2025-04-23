#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# mp4_to_apng.py
# This script converts MP4 video files found in the 'mp4' directory
# into animated PNG (APNG) files and saves them in the 'export' directory.
# It uses the external 'ffmpeg' command-line tool.

import os
import subprocess
import logging
import sys
from pathlib import Path

# --- Configuration ---

# Directory containing the input MP4 files
MP4_SOURCE_DIR = "mp4"
# Directory where the output APNG files will be saved
APNG_EXPORT_DIR = "export"
# Log file name
LOG_FILE = "conversion.log"
# FFmpeg command options
# -i : input file (will be added later)
# -vf "fps=15,scale=320:-1:flags=lanczos" : Video filter options
#    fps=15 : Set the frame rate to 15 FPS (adjust as needed)
#    scale=320:-1 : Resize video width to 320px, height adjusted automatically (-1)
#    flags=lanczos : Use lanczos scaling algorithm (good quality)
# -plays 0 : Loop the APNG indefinitely (use -plays 1 for no loop)
# -f apng : Force the output format to APNG
# -y : Overwrite output files without asking
FFMPEG_OPTIONS = ["-vf", "fps=15,scale=320:-1:flags=lanczos", "-plays", "0", "-f", "apng", "-y"]

# --- Setup Logging ---

# Create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG) # Log everything from DEBUG level upwards

# Create file handler which logs even debug messages
fh = logging.FileHandler(LOG_FILE, mode='w') # Overwrite log file each run
fh.setLevel(logging.DEBUG)

# Create console handler with a higher log level (e.g., INFO)
ch = logging.StreamHandler(sys.stdout) # Log to console
ch.setLevel(logging.INFO)

# Create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
fh.setFormatter(formatter)
ch.setFormatter(formatter)

# Add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)

# --- Helper Functions ---

def check_ffmpeg():
    """Checks if the ffmpeg command is available in the system PATH."""
    logger.info("Checking for ffmpeg executable...")
    try:
        # Use subprocess.run to check for ffmpeg, suppressing output
        subprocess.run(["ffmpeg", "-version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        logger.info("ffmpeg found.")
        return True
    except FileNotFoundError:
        logger.error("FATAL: ffmpeg command not found. Please ensure ffmpeg is installed and accessible in your PATH.")
        return False
    except subprocess.CalledProcessError as e:
        logger.error(f"FATAL: Error while checking ffmpeg version: {e}")
        return False

def convert_mp4_to_apng(mp4_filepath, apng_filepath):
    """
    Converts a single MP4 file to APNG using ffmpeg.

    Args:
        mp4_filepath (Path): Path object for the input MP4 file.
        apng_filepath (Path): Path object for the output APNG file.

    Returns:
        bool: True if conversion was successful, False otherwise.
    """
    logger.info(f"Starting conversion for: {mp4_filepath.name}")
    logger.debug(f"Input path: {mp4_filepath}")
    logger.debug(f"Output path: {apng_filepath}")

    # Construct the ffmpeg command
    # Example: ffmpeg -i input.mp4 -vf "fps=15,scale=320:-1:flags=lanczos" -plays 0 -f apng -y output.apng
    command = [
        "ffmpeg",
        "-i", str(mp4_filepath),  # Input file
        *FFMPEG_OPTIONS,          # Spread the list of options
        str(apng_filepath)        # Output file
    ]

    logger.debug(f"Executing command: {' '.join(command)}")

    try:
        # Execute the command
        # capture_output=True captures stdout and stderr
        # text=True decodes stdout/stderr as text
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        logger.info(f"Successfully converted '{mp4_filepath.name}' to '{apng_filepath.name}'")
        logger.debug(f"ffmpeg stdout:\n{result.stdout}")
        logger.debug(f"ffmpeg stderr:\n{result.stderr}") # ffmpeg often logs progress to stderr
        return True
    except FileNotFoundError:
        # This case should ideally be caught by check_ffmpeg, but good to have redundancy
        logger.error(f"Error converting {mp4_filepath.name}: ffmpeg command not found.")
        return False
    except subprocess.CalledProcessError as e:
        # This catches errors from ffmpeg itself (e.g., invalid file, bad options)
        logger.error(f"Error converting {mp4_filepath.name}. ffmpeg exited with status {e.returncode}.")
        logger.error(f"ffmpeg stderr:\n{e.stderr}") # Show the error output from ffmpeg
        return False
    except Exception as e:
        # Catch any other unexpected errors
        logger.error(f"An unexpected error occurred during conversion of {mp4_filepath.name}: {e}")
        return False

# --- Main Execution ---

def main():
    """Main function to orchestrate the conversion process."""
    logger.info("--- MP4 to APNG Conversion Script Started ---")

    # 1. Check for ffmpeg
    if not check_ffmpeg():
        sys.exit(1) # Exit if ffmpeg is not available

    # 2. Define and check source and export directories
    base_dir = Path(__file__).parent # Get the directory where the script is located
    source_dir = base_dir / MP4_SOURCE_DIR
    export_dir = base_dir / APNG_EXPORT_DIR

    logger.info(f"Source directory: {source_dir}")
    logger.info(f"Export directory: {export_dir}")

    if not source_dir.is_dir():
        logger.error(f"Source directory '{source_dir}' not found. Please create it and place your MP4 files inside.")
        sys.exit(1)

    if not export_dir.is_dir():
        logger.info(f"Export directory '{export_dir}' not found. Creating it now.")
        try:
            export_dir.mkdir(parents=True, exist_ok=True)
        except OSError as e:
            logger.error(f"Failed to create export directory '{export_dir}': {e}")
            sys.exit(1)

    # 3. Find MP4 files in the source directory
    mp4_files = list(source_dir.glob("*.mp4"))

    if not mp4_files:
        logger.warning(f"No MP4 files found in '{source_dir}'. Nothing to convert.")
        logger.info("--- Conversion Script Finished (No Files) ---")
        sys.exit(0)

    logger.info(f"Found {len(mp4_files)} MP4 file(s) to process.")

    # 4. Process each MP4 file
    success_count = 0
    failure_count = 0

    for mp4_file_path in mp4_files:
        # Create a unique output filename based on the input filename
        # Removes the .mp4 extension and adds .apng
        output_filename = mp4_file_path.stem + ".apng"
        apng_file_path = export_dir / output_filename

        if convert_mp4_to_apng(mp4_file_path, apng_file_path):
            success_count += 1
        else:
            failure_count += 1
            # Optional: Move failed files to a separate directory? Or just log.

    # 5. Log summary
    logger.info("--- Conversion Summary ---")
    logger.info(f"Total files processed: {len(mp4_files)}")
    logger.info(f"Successful conversions: {success_count}")
    logger.info(f"Failed conversions: {failure_count}")
    logger.info(f"Log file saved to: {base_dir / LOG_FILE}")
    logger.info(f"Converted APNG files are in: {export_dir}")
    logger.info("--- MP4 to APNG Conversion Script Finished ---")

    if failure_count > 0:
        sys.exit(1) # Exit with error code if any conversion failed
    else:
        sys.exit(0) # Exit successfully

if __name__ == "__main__":
    # This ensures the main function is called only when the script is executed directly
    main()

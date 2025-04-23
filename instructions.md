instructions.md
# Instructions: MP4 to APNG Conversion Tool

This guide explains how to use the provided scripts to convert your MP4 video files into animated PNG (APNG) files within your WSL (Windows Subsystem for Linux) environment.

**Goal:** To take `.mp4` files from an `mp4/` folder and create looping `.apng` files in an `export/` folder.

**Core Tool:** We use `ffmpeg`, a very powerful open-source command-line tool for handling video and audio. The Python script (`mp4_to_apng.py`) acts as a manager, finding your files and telling `ffmpeg` exactly how to convert each one.

**Why Python & Bash?**
* **Bash (`.sh` files):** Great for automating command-line tasks in Linux/WSL, like installing software (`apt`), managing directories (`mkdir`, `rm`), and running other scripts.
* **Python (`.py` file):** Excellent for more complex logic like finding specific files, constructing commands dynamically, handling errors gracefully, and logging detailed information. It's easier to manage the conversion process for multiple files in Python than in pure Bash.
* **Virtual Environment (`venv`):** Python projects can have dependencies (other code libraries they need). A virtual environment creates an isolated space for your project's dependencies, preventing conflicts with other Python projects or system-wide Python packages. It's standard practice for Python development.

## Prerequisites

* **WSL Installed:** You need a working WSL distribution (like Ubuntu) set up on your Windows machine.
* **Basic Terminal Knowledge:** You should be comfortable opening your WSL terminal and running basic commands like `cd` (change directory) and `ls` (list files).
* **`sudo` Access:** The setup script needs administrator privileges (`sudo`) to install software using `apt`. You'll likely be prompted for your WSL user password.

## Files Overview

* `mp4/`: **Input directory.** Place the MP4 files you want to convert here.
* `export/`: **Output directory.** The converted APNG files will appear here.
* `initialize_project.sh`: **(Run Once First)** Sets up the `mp4/`, `export/` folders, creates this `README.md`, and initializes a Git repository (for version control, optional but good practice).
* `setup_env.sh`: **(Run Once After Init)** Installs `ffmpeg`, `python3`, `pip` (Python's package manager), and `python3-venv` if they are missing. It also creates the Python virtual environment (`venv/` folder). Tracks installed packages in `.installed_packages`.
* `mp4_to_apng.py`: The core Python script that finds MP4s and uses `ffmpeg` to convert them. You don't usually run this directly.
* `run_conversion.sh`: **(Run Whenever Needed)** Activates the virtual environment and runs the `mp4_to_apng.py` script to perform the conversions.
* `cleanup.sh`: **(Run When Done)** Uninstalls the packages that `setup_env.sh` installed and removes the `venv/` folder.
* `conversion.log`: A log file created by the Python script, recording details of the conversion process (useful for debugging).
* `INSTRUCTIONS.md`: This file.
* `.gitignore`: Tells Git which files/folders to ignore (like the `venv` and large media files).
* `.installed_packages`: A hidden file created by `setup_env.sh` to remember which packages it installed, so `cleanup.sh` knows what to remove.

## Step-by-Step Usage

1.  **Save the Scripts:**
    * Save all the code blocks provided (`initialize_project.sh`, `setup_env.sh`, `mp4_to_apng.py`, `run_conversion.sh`, `cleanup.sh`, and this `INSTRUCTIONS.md`) into a new folder in your WSL environment. Let's call the folder `mp4-converter`.

2.  **Open WSL Terminal:**
    * Open your WSL terminal (e.g., Ubuntu).
    * Navigate to the directory where you saved the scripts:
        ```bash
        cd path/to/your/mp4-converter
        ```
        (Replace `path/to/your/` with the actual path).

3.  **Make Scripts Executable:**
    * Bash scripts need permission to run. Execute this command once:
        ```bash
        chmod +x *.sh
        ```
        This gives execute (`+x`) permission to all files ending in `.sh`.

4.  **Initialize Project Structure:**
    * Run the initialization script:
        ```bash
        ./initialize_project.sh
        ```
    * This will create the `mp4/` and `export/` subdirectories and the `README.md` and `.gitignore` files. It will also initialize a Git repository.

5.  **Add MP4 Files:**
    * Copy or move the `.mp4` files you want to convert into the newly created `mp4/` directory.

6.  **Set Up Environment & Dependencies:**
    * Run the setup script. You might be asked for your password because it uses `sudo` to install software.
        ```bash
        ./setup_env.sh
        ```
    * This script checks for `ffmpeg`, `python3`, `pip`, and `python3-venv`. If any are missing, it will attempt to install them using `apt`. It then creates the `venv/` directory (the Python virtual environment). Watch the output for any errors.

7.  **Run the Conversion:**
    * Execute the run script:
        ```bash
        ./run_conversion.sh
        ```
    * This script does two main things:
        * Activates the `venv` environment.
        * Runs the `mp4_to_apng.py` Python script.
    * You'll see output in the terminal showing the progress. Check the `export/` directory for your `.apng` files. Also, check the `conversion.log` file for detailed logs, especially if errors occur.

8.  **Review Output:**
    * Check the `export/` folder for your APNG files.
    * Open them in a viewer that supports APNG (most modern web browsers do) to ensure they look correct and loop as expected.
    * If you encounter errors, check the terminal output and the `conversion.log` file for clues.

9.  **Clean Up (Optional):**
    * If you want to remove the software installed by `setup_env.sh` and the virtual environment to keep your WSL tidy, run the cleanup script:
        ```bash
        ./cleanup.sh
        ```
    * It will ask for `sudo` permission again to remove the packages. It reads the `.installed_packages` file to know exactly which packages to remove. It will also ask if you want to delete the `conversion.log` file.

## Customization (Optional)

* **Conversion Settings:** You can modify the `FFMPEG_OPTIONS` list near the top of the `mp4_to_apng.py` script to change things like:
    * `fps=15`: Change `15` to a different frame rate. Higher FPS means smoother animation but larger file size.
    * `scale=320:-1`: Change `320` to a different width (in pixels). `-1` automatically calculates the height to maintain aspect ratio.
    * `-plays 0`: `0` means loop forever. `1` means play once.
* **Filenames:** The script currently names output files like `input_video.apng`. You could modify the Python script (`output_filename = ...`) if you need a different naming scheme.

Good luck with your conversions!

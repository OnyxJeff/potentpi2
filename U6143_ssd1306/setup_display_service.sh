#!/bin/bash

# Script to configure the C display program to run on boot via systemd service.
# Dynamically detects the repository path and compiles the program once.

SERVICE_NAME="uctronics-display"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "--- UCTRONICS C Display Systemd Service Setup Script ---"

# 1. Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with sudo."
  echo "Please run as: sudo $0"
  exit 1
fi

# --- Dynamic Path Configuration ---
# 2. Auto-detect the repo base directory from the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BASE_DIR="$SCRIPT_DIR"

echo "Detected repository base directory (script location): $REPO_BASE_DIR"

# 3. Define C program paths
C_DIR="$REPO_BASE_DIR/C"             # Directory containing C source code and Makefile
MAKEFILE_PATH="$C_DIR/Makefile"      # Full path to the Makefile
EXECUTABLE_PATH="$C_DIR/display"     # Path to the compiled executable

echo "Assuming C program path: $C_DIR"
echo "Assuming Makefile path: $MAKEFILE_PATH"
# --- End Dynamic Path Configuration ---

# 4. Check if the C directory and Makefile exist
if [ ! -d "$C_DIR" ]; then
  echo "Error: C program directory not found: $C_DIR"
  exit 1
fi
if [ ! -f "$MAKEFILE_PATH" ]; then
  echo "Error: Makefile not found: $MAKEFILE_PATH."
  exit 1
fi

# 5. Compile the program (as root since the script runs with sudo)
echo "Compiling the C program in $C_DIR..."
make -C "$C_DIR" clean
make -C "$C_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Failed to compile the program using 'make' in $C_DIR."
    exit 1
fi

# Check if executable exists after compilation
if [ ! -x "$EXECUTABLE_PATH" ]; then
    echo "Error: Compiled executable '$EXECUTABLE_PATH' not found or not executable after running make."
    exit 1
fi
echo "Compilation successful. Executable created at: $EXECUTABLE_PATH"


# 6. Check if the service file already exists
if [ -f "$SERVICE_FILE" ]; then
  echo "Warning: Service file $SERVICE_FILE already exists."
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo # Move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting. No changes made."
    exit 1
  fi
  echo "Overwriting existing service file."
fi

# 7. Create the systemd service file content
# Note: Runs as root by default. Change 'User=' if it should run as a different user.
# Ensure that user has necessary hardware access permissions (e.g., i2c, gpio groups).
# If the program needs access to hardware, running as root might be necessary,
# or the user specified needs to be in the correct groups (e.g., i2c, gpio).
# Using 'root' here aligns with rc.local's default behavior.
echo "Creating systemd service file: $SERVICE_FILE"
cat << EOF > "$SERVICE_FILE"
[Unit]
Description=UCTRONICS C Display Service ($REPO_NAME)
# Start after basic system initialization and multi-user environment is up
After=multi-user.target

[Service]
# Consider changing User= to $SUDO_USER if root privileges are not strictly required
# and the user $SUDO_USER has the necessary hardware permissions (e.g., added to i2c/gpio groups)
User=root
# Group= Baset on User
WorkingDirectory=$C_DIR
# Execute the compiled program. Do NOT use '&'. systemd handles backgrounding.
ExecStart=$EXECUTABLE_PATH
Restart=on-failure # Restart the service if the program crashes
RestartSec=5s      # Wait 5 seconds before restarting

[Install]
WantedBy=multi-user.target
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to write service file $SERVICE_FILE."
    exit 1
fi

# 8. Reload systemd, enable and start the service
echo "Reloading systemd daemon..."
systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd daemon."
    # Attempt to clean up the potentially broken service file
    rm -f "$SERVICE_FILE"
    exit 1
fi

echo "Enabling the service to start on boot..."
systemctl enable "$SERVICE_NAME.service"
if [ $? -ne 0 ]; then
    echo "Error: Failed to enable the service $SERVICE_NAME."
    # Attempt to clean up the service file
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload # Reload again after removing
    exit 1
fi

echo "Starting the service now..."
systemctl start "$SERVICE_NAME.service"
if [ $? -ne 0 ]; then
    # If start fails, the service might still be enabled for next boot. Inform user.
    echo "Warning: Failed to start the service $SERVICE_NAME immediately."
    echo "It might still be enabled to start on the next boot."
    echo "Check the service status with: sudo systemctl status $SERVICE_NAME.service"
    echo "Check logs with: sudo journalctl -u $SERVICE_NAME.service"
else
    echo "Service $SERVICE_NAME created, enabled, and started successfully."
fi

echo "-----------------------------------------------------"
echo "Setup complete. The display program should now be running and configured to start on boot."
echo "You can manage the service using commands like:"
echo "  sudo systemctl status $SERVICE_NAME.service   # Check status"
echo "  sudo systemctl stop $SERVICE_NAME.service    # Stop the service"
echo "  sudo systemctl start $SERVICE_NAME.service   # Start the service"
echo "  sudo systemctl disable $SERVICE_NAME.service # Prevent starting on boot"
echo "  sudo journalctl -u $SERVICE_NAME.service   # View logs"
echo "-----------------------------------------------------"

exit 0
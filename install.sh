#!/bin/bash

TARGET_DIR="$HOME"
SOURCE_DIR="."

# First do dry run
echo "Starting dry run of GNU stow..."
DRY_RUN_OUTPUT=$(stow --simulate --target $TARGET_DIR $SOURCE_DIR 2>&1)
echo

if echo $DRY_RUN_OUTPUT | head -n2 | tail -n1 | grep -qE "^(WARNING|LINK)"; then
    echo "Configuration seems to be already up-to-date. Aborting Installation..."
else
    read -p "Proceed with Installation? (y/n): " CONFIRMATION

    if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
        echo "Deploying configuration files..."
        stow --target $TARGET_DIR $SOURCE_DIR
        echo "Installation complete!"
    else
        echo "Installation canceled."
    fi
fi


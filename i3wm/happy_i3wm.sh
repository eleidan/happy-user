#!/usr/bin/env bash

# Install i3wm itself
# sudo apt-get install i3

# Install dependencies
# sudo apt-get install xbacklight

# Fetch repo with a script and copy some stuff into /usr/bin/
# TODO
echo "Copy "
SRC_DIR="/tmp"
DEST_DIR="$HOME/.local/bin"
if [[ $(echo $PATH | grep -i "${DEST_DIR}") ]]; then
  cp ${SRC_DIR}/toggle_touchpad ${DEST_DIR} &&
    echo "Done."
else
  echo "NO..."

fi

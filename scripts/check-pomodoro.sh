#!/usr/bin/env bash

# macOS only: a Raycast script command (see the @raycast metadata below)
# that shows how long the current timewarrior interval has been running.

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check Pomodoro
# @raycast.packageName Pomodoro Timer
# @raycast.mode compact
# @raycast.refreshTime 10s

# Optional parameters:
# @raycast.icon ⏳

# Check progress of active timewarrior task
timew | grep "Total" | awk '{print "⏳ Pomodoro: " $2 " " $3}'

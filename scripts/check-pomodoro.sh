#!/bin/bash

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

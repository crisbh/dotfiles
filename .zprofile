
# -------------------------------------------------
# TODO system 
# -------------------------------------------------
# Run todo watcher only if it's not already running
if ! pgrep -f "fswatch -o" >/dev/null; then
    echo "Starting watch-todos script..."
    # nohup /opt/homebrew/bin/bash ~/.dotfiles/scripts/watch-todos >/dev/null 2>&1 &
    nohup ~/.dotfiles/scripts/watch-todos >/tmp/watch-todos.log 2>&1 &
fi


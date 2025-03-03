#
# The following code starts monitoring the notes so the collect script will
# collect TODO items as soon as a note file is modified.
#
# NOTE: This has been deprecated since now I'm using a collect-on-write approach.
#
 
# # -------------------------------------------------
# # TODO system 
# # -------------------------------------------------
# # Run todo watcher only if it's not already running
# if ! pgrep -f "fswatch -o" >/dev/null; then
#     echo "Starting watch-todos script..."
#     nohup ~/.dotfiles/scripts/watch-todos >/tmp/watch-todos.log 2>&1 &
# fi
#

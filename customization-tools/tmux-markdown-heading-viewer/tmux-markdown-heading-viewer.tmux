#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux unbind-key -T prefix m         
tmux unbind-key -T prefix M        
tmux bind-key m run-shell "tmux display-popup -y 20 -w 100 -h 85% -E bash $CURRENT_DIR/bin/tmux-markdown-heading-viewer.sh"
tmux bind-key M run-shell "tmux display-popup -y 20 -w 100 -h 85% -E bash $CURRENT_DIR/bin/tmux-markdown-heading-viewer.sh reset"

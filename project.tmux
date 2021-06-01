#!/bin/bash
tmux new -s defaultprojectname -d
tmux rename-window -t 0 vim
tmux send-keys -t defaultprojectname:vim "vim" C-m
tmux new-window -t defaultprojectname -n shell -d
tmux split-window -t defaultprojectname:shell -v
tmux select-window -t defaultprojectname:vim
tmux attach -t defaultprojectname

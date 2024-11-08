#!/bin/bash
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
if ! ssh-add -l &>/dev/null; then
     echo Adding keys...
     ssh-add
fi

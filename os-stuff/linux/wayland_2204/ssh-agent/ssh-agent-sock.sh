# set ssh environment variables for wayland since that is not done in a wayland environment
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

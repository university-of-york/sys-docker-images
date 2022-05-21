#!/usr/bin/env bash
#
# Deploy a repository via rsync, then run a command or script on your server
#
# Required globals:
#   SSH_KEY
#   SSH_USER
#   RSYNC_USER
#   SERVER
#
# Optional globals:
#   LOCAL_PATH (default: "./" - i.e. the repository root)
#   REMOTE_PATH (default: "/") - you probably (should) have command=rrsync
#       set in authorized_keys anyway...
#   COMMAND (default: "false") - you probably (should) have command= set in
#       authorized_keys anyway...
#   RSYNC_ARGS - extra arguments for rsync, if you want (unescaped)
#   DEBUG (default: "false")
#   SSH_KEY (default: null)
#   PORT (default: 22)
#   CHMOD (default: g-w,o-rwx)
#

source "$(dirname "$0")/common.sh"

info "Executing the pipe..."

validate() {
  # required parameters
  : SSH_KEY=${SSH_KEY:?'SSH_KEY variable missing.'}
  : SSH_USER=${SSH_USER:?'SSH_USER variable missing.'}
  : RSYNC_USER=${RSYNC_USER:?'RSYNC_USER variable missing.'}
  : SERVER=${SERVER:?'SERVER variable missing.'}
  : LOCAL_PATH=${MODE:="./"}
  : REMOTE_PATH=${MODE:="/"}
  : CHMOD=${CHMOD:="g-w,o-rwx"}
  : COMMAND=${COMMAND:="false"}
  : DEBUG=${DEBUG:="false"}
}

setup_ssh_dir() {

  mkdir -p $HOME/.ssh || debug "adding ssh keys to existing $HOME/.ssh"
  touch $HOME/.ssh/authorized_keys

  # Set the provided SSH key
  if [ -n "${SSH_KEY}" ]; then
    # Write the provided SSH key
    info "Using provided SSH_KEY"

    #Convert the key from a single str to multiline RSA key
  	echo ${SSH_KEY} | sed -e "s/-----BEGIN RSA PRIVATE KEY-----/&\n/"\
  	    -e "s/-----END RSA PRIVATE KEY-----/\n&/"\
  	    -e "s/\S\{64\}/&\n/g" | sed "s/^\s//g" > $HOME/.ssh/actions_rsa

    # Set the key permissions
    chmod 0700 $HOME/.ssh/actions_rsa
  fi

  if [ -f $HOME/.ssh/config ]; then
      debug "Appending to existing $HOME/.ssh/config file"
  fi
  echo "IdentityFile $HOME/.ssh/actions_rsa" >> $HOME/.ssh/config
  chmod -R go-rwx $HOME/.ssh/
}

run_pipe() {
  info "Deploying ${LOCAL_PATH} to ${REMOTE_PATH} on ${SERVER}"

  if [[ -n "${PORT}" ]]; then
    run rsync -rp --chmod="$CHMOD" --delete-after ${RSYNC_ARGS} -e "ssh -i $HOME/.ssh/actions_rsa -o StrictHostKeyChecking=no -p ${PORT}" "${LOCAL_PATH}" "${RSYNC_USER}@${SERVER}:${REMOTE_PATH}"
  else
    run rsync -rp --chmod="$CHMOD" --delete-after ${RSYNC_ARGS} -e "ssh -i $HOME/.ssh/actions_rsa -o StrictHostKeyChecking=no" "${LOCAL_PATH}" "${RSYNC_USER}@${SERVER}:${REMOTE_PATH}"
  fi

  if [[ "${status}" == "0" ]]; then
    success "Deployment finished."
  else
    fail "Deployment failed."
  fi

  info "Executing command on ${SERVER}"
  run ssh -A -tt -i $HOME/.ssh/actions_rsa -p "${PORT:-22}" -l "$SSH_USER" "$SERVER" "$COMMAND"

  if [[ "${status}" == "0" ]]; then
    success "Execution finished."
  else
    fail "Execution failed."
  fi
}

validate
enable_debug
setup_ssh_dir
run_pipe

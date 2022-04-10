#!/bin/bash

export HETZNER_IP=78.46.81.50

MYVMIP=192.168.122.14
MYDEVIP=192.168.122.162

sshmgm() {
  ssh magma@${MYVMIP}
}

sshbare() {
  ssh lakshman@${HETZNER_IP}
}

sshbareasroot() {
  ssh asroot@${HETZNER_IP}
}

tnewh() {
    python /home/lakshman/github/quick-utility-scripts/tmux_starter/tnew.py "$@"
}

tnewn() {
    tnewh -n "$@"
}
alias tnew=tnewn

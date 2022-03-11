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

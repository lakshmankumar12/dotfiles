#!/bin/bash

export HETZNER_IP=78.46.81.50

MYVMIP=192.168.122.14
MYDEVIP=192.168.122.162

ARTIFACTORY_IP=10.233.6.148
JENKINS_IP=10.233.47.126

sshmgm() {
  ssh hostvm
}

sshbare() {
  ssh bare
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

startjenkinstunnel() {
    ssh -o ExitOnForwardFailure=yes -L 10000:$JENKINS_IP:8080 localhost
}

downloadfromartifactory() {
    if [ -z "$1" ] ; then
        echo "supply url"
        return 1
    fi
    url="$1"
    file=${url##*/}
    #url=$(echo $url | sed "s#https://artifactory.gxc.io/#http://$ARTIFACTORY_IP:8081/#")
    setup_gxc_build_creds
    cmd="curl --user $GXC_CREDS $url -o $file"
    echo "Executing $cmd"
    eval $cmd
}

downloadfromtr0jenkins() {
    if [ -z "$1" ] ; then
        echo "supply url"
        return 1
    fi
    url="$1"
    file=${url##*/}
    setup_lakshman_tr0jenkins_cred
    curl --user $LAKSHMAN_TR0JENKINS_CREDS $url -o $file
}

downloadfrommainjenkins() {
    if [ -z "$1" ] ; then
        echo "supply url"
        return 1
    fi
    url="$1"
    file=${url##*/}
    setup_main_jenkins_cred
    curl -C - --user $MAIN_JENKINS_CREDS $url -o $file

}

pushmagmadebtoartifactory() {
    if [ -z "$1" ] ; then
        echo "supply DEB file name (it has to be in pwd)"
        return 1
    fi
    DEB="$1"
    setup_artifactory_admin_creds
    cmd="curl -v -u '$ARTIFACTORY_CREDS' -H 'Content-Type: multipart/form-data' --data-binary '@./${DEB}' http://10.233.6.148:8081/repository/onyx-apt-repo/"
    echo "executing:"
    echo $cmd
    eval $cmd
}

extract_from_gxc_tar() {
    extract_path="$1"
    tar -Oxf gxc_magma_agw_tr0.tar.gz gxc_magma_agw.tar.gz | tar xzf - --wildcards "$extract_path"
}

get_iso_from_hostvm_and_put_in_bare() {
    if [ -z "$1" ] ; then
        echo "Supply iso name"
        return 1
    fi
    iso="$1"
    src_path=/home/magma/genxcomm/onyx-corenw/lte/gateway/magma_builder/iso_creator/$iso
    scp hostvm:$src_path $iso
    ssh bare rm -f /home/lakshman/linux-isos/$iso
    scp $iso bare:/home/lakshman/linux-isos/
    ssh bare ln -sf /home/lakshman/linux-isos/$iso /home/lakshman/linux-isos/magma_unattended_ubuntu.iso
    rm $iso
}

cp_from_magma_cache() {
    if [ -z "$1" ] ; then
        echo "Supply file to cp"
        return 1
    fi
    cp /magma_vm/genxcomm/onyx-corenw/.cache/"$1" ~/tmp/
    date
    ls -rlt ~/tmp/"$1"
}

sshagw() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    ssh -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no onyxedge@"$1"
}

scpfromagw() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    agw="$1"; shift
    if [ -z "$1" ] ; then
        echo "Supply file"
        return 1
    fi
    file="$1"
    scp -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no onyxedge@"$agw":"$file" .
}

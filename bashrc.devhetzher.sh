#!/bin/bash

export HETZNER_IP=78.46.81.50

MYVMIP=192.168.122.14
MYDEVIP=192.168.122.162

ARTIFACTORY_IP=10.233.6.148
JENKINS_IP=10.233.47.126

alias tkts='cd /magma_vm/ticket_logs'

jira() {
    python3 /home/lakshman/gitlab/genxcomm-scripts/jira/download_jira.py "$@"
}

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

pushtoartifactory() {
    if [ -z "$1" ] ; then
        echo "Supply repo name"
        return 1
    fi
    repo="$1"
    shift
    if [ -z "$1" ] ; then
        echo "Supply filename (Must be inside of pwd)"
        return 1
    fi
    file="$1"
    shift
    binary="--upload-file '"
    if [ -n "$1" ] ; then
        binary="-H 'Content-Type: multipart/form-data' --data-binary '@./"
    fi
    setup_artifactory_admin_creds
    cmd="curl -v -u '$ARTIFACTORY_CREDS' ${binary}${file}' http://localhost:32777/repository/$repo/"
    echo "executing:"
    echo $cmd
    eval $cmd
}
pushmagmadebtoartifactory() {
    if [ -z "$1" ] ; then
        echo "supply DEB file name (it has to be in pwd)"
        return 1
    fi
    pushtoartifactory onyx-apt-repo "$1" "binary"
}
pushtoreleasetarartifactory() {
    if [ -z "$1" ] ; then
        echo "supply file name (it has to be in pwd)"
        return 1
    fi
    pushtoartifactory release-tar "$1" ""
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

sshagwargs() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    agw="$1"
    shift
    if [ -z "$1" ] ; then
        echo "Supply username to login"
        return 1
    fi
    user="$1"
    ssh -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "${user}"@"${agw}"
}

sshagw() {
    sshagwargs "$1" onyxedge
}
sshec2() {
    sshagwargs $(cat ~/.curr_aws_ec2_ip) onyxedge
}
currec2() {
    cat ~/.curr_aws_ec2_ip
}
setcurrec2() {
    if [ -z "$1" ] ; then
        echo "Supply IP"
        return 1
    fi
    echo "$1" > ~/.curr_aws_ec2_ip
}

sshagwdiffuser() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    ip="$1"
    shift
    if [ -z "$1" ] ; then
        echo "Supply username to login"
        return 1
    fi
    user="$1"
    ssh -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${user}@${ip}
}


scpfromagwdiffuser() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    agw="$1"; shift
    if [ -z "$1" ] ; then
        echo "Supply file"
        return 1
    fi
    file="$1" ; shift
    if [ -z "$1" ] ; then
        echo "Supply user"
        return 1
    fi
    user="$1"
    scp -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@"$agw":"$file" .
}
scpfromagw() {
    agw="$1"
    file="$2"
    scpfromagwdiffuser "$agw" "$file" "onxyedge"
}

scptoagwdiffuser() {
    if [ -z "$1" ] ; then
        echo "Supply AGW to login"
        return 1
    fi
    agw="$1"; shift
    if [ -z "$1" ] ; then
        echo "Supply file"
        return 1
    fi
    file="$1" ; shift
    if [ -z "$1" ] ; then
        echo "Supply user"
        return 1
    fi
    user="$1"
    scp -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$file" $user@"$agw":/tmp/
}


scpdebtoanyagw() {
    agw="$1"
    ssh -i ~/.ssh/tr0_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no onyxedge@$agw /bin/bash -c "'rm -f /tmp/magma_*_amd64.deb'"
    debs=($(/usr/bin/ls /magma_vm/genxcomm/gxc_magma/pkg/magma_*deb))
    if [ ${#debs[@]} -ne 1 ] ; then
        echo "Incorrect no-debs in /magma_vm/genxcomm/gxc_magma/pkg/ . Count: ${#debs[@]}"
        return
    fi
    echo "copying ${debs[0]}"
    scptoagwdiffuser "$agw" "${debs[0]}" onyxedge
}
scpdebtodagw() {
    scpdebtoanyagw "dagw"
}

update_aws_kubecfg() {
    aws eks update-kubeconfig --region ${REGION} --name orc8r
}

set_dev_orc8r() {
    REGION="us-east-1"
    update_aws_kubecfg
    dir=/magma_vm/aws_orc8rs/aws-magmaorc8r-dev/secrets_dev/certs
    mykey=${dir}/admin_operator.key.pem
    mycert=${dir}/admin_operator.pem
    orcurl="api.dev-gxcnetwork.com"
    cacert_arg=""
    rootcert=""
    resolve_cmd=""
    resolve_str=""
}

set_qa_orc8r() {
    REGION="us-east-2"
    update_aws_kubecfg
    dir=/magma_vm/aws_orc8rs/aws-magmaorc8r-qa/secrets_qa/certs
    mykey=${dir}/admin_operator.key.pem
    mycert=${dir}/admin_operator.pem
    orcurl="api.generationxcomm.com"
    resolve_cmd=""
    resolve_str=""
    cacert_arg=""
    rootcert=""
}

set_svt_orc8r() {
    REGION="us-west-2"
    update_aws_kubecfg
    dir=/magma_vm/aws_orc8rs/aws-magmaorc8r-svt/secrets_svt/certs
    mykey=${dir}/admin_operator.key.pem
    mycert=${dir}/admin_operator.pem
    orcurl="api.gxcnetwork.com"
    cacert_arg=""
    rootcert=""
    resolve_cmd=""
    resolve_str=""
}

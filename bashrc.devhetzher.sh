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
scpdebtodagwstatic() {
    scpdebtoanyagw "dagwstatic"
}

start_remote_access() {
    if [ -z "$session_name" ] ; then
        echo "set session_name"
        return 1
    fi
    public_ip_of_machine=142.132.204.245
    user=remoteagwuser
    duration=7200
    port=48555
    notify_file=/home/remoteagwuser/${session_name}
    MAGMA_ROOT=/magma_vm/genxcomm/onyx-corenw
    ${MAGMA_ROOT}/lte/gateway/gxc_files/remote_access/prepare_instructions.sh -s $public_ip_of_machine -p 22 -u ${user} -l ${port} -n ${notify_file} -S ${session_name} -d ${duration} > /dev/null
    cat key_${session_name}.pub  | tr -d '\n' | totmuxclip
    echo "tmux clip is set with pub-key. Add this to remagwother"
    echo "Later do"
    echo 'cat instruction_to_copy | hhc'
    echo 'ssh lakshman_remote_session'
}


#### BEGIN ORC FNS BLOCK

set_local_orc8r() {
    server=192.168.122.14
    mykey=${MAGMA_ROOT}/orc8r/cloud/helm/orc8r/charts/secrets/certs/admin_operator.key.pem
    mycert=${MAGMA_ROOT}/orc8r/cloud/helm/orc8r/charts/secrets/certs/admin_operator.pem
    orcurl="anybody.magma.test:32630"
    cacert_arg="--cacert"
    rootcert=${MAGMA_ROOT}/orc8r/cloud/helm/orc8r/charts/secrets/certs/rootCA.pem
    resolve_cmd="--resolve"
    resolve_str="anybody.magma.test:32630:$server"
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
    cacert_arg=""
    rootcert=""
    resolve_cmd=""
    resolve_str=""
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

set_prod_orc8r() {
    REGION="us-east-2"
    update_aws_kubecfg
    dir=/magma_vm/aws_orc8rs/aws-magmaorc8r-prod/secrets_prod/certs
    mykey=${dir}/admin_operator.key.pem
    mycert=${dir}/admin_operator.pem
    orcurl="api.genxcom.com"
    cacert_arg=""
    rootcert=""
    resolve_cmd=""
    resolve_str=""
}

post() {
    echo "${newdata}" > /tmp/data.txt
    cmd=$(echo curl --cert $mycert --key $mykey "${cacert_arg}" "$rootcert" -X POST "${resolve_cmd}" "${resolve_str}" "'$url'" -H "accept:application/json" -H "content-type:application/json" -d "@/tmp/data.txt")
    echo "Running cmd: ${cmd}"
    eval ${cmd}
}
put() {
    echo "${newdata}" > /tmp/data.txt
    cmd=$(echo curl --cert $mycert --key $mykey "${cacert_arg}" "$rootcert" -X PUT "${resolve_cmd}" "${resolve_str}" "'$url'" -H "accept:application/json" -H "content-type:application/json" -d "@/tmp/data.txt")
    echo "Running cmd: ${cmd}"
    eval ${cmd}
}
getn() {
    rm -f /tmp/last_data
    cmd=$(echo curl --cert $mycert --key $mykey "${cacert_arg}" "$rootcert" -X GET "${resolve_cmd}" "${resolve_str}" "'$url'" -H "accept:application/json")
    echo "Running cmd: ${cmd}"
    eval ${cmd} -o /tmp/last_data
    data="$(cat /tmp/last_data | jq '.')"
    newdata="${data}"
}
get() {
    getn
    echo "$data" | less
}

filedn() {
    rm -f /tmp/last_data
    cmd=$(echo curl --cert $mycert --key $mykey "${cacert_arg}" "$rootcert" -X GET "${resolve_cmd}" "${resolve_str}" "'$url'" -H "accept:application/octet-stream")
    echo "Running cmd: ${cmd}"
    eval ${cmd} -o /tmp/last_data
    data="$(cat /tmp/last_data)"
    echo "$data"
}
filednpg() {
    filedn | less
}
del() {
    cmd=$(echo curl --cert $mycert --key $mykey "${cacert_arg}" "$rootcert" -X DELETE "${resolve_cmd}" "${resolve_str}" "'$url'" -H "accept:application/json")
    echo "Running cmd: ${cmd}"
    eval ${cmd}
}


getwhat() {
    what="${what#/}" ; if [ -n "$what" ] ; then what="/${what}" ; fi
    url="${url}/${what}"
    get
}
putwhat() {
    what="${what#/}" ; if [ -n "$what" ] ; then what="/${what}" ; fi
    url="${url}/${what}"
    put
}


nw_all() {
    url="https://${orcurl}/magma/v1/lte"
}
nw_one() {
    url="https://${orcurl}/magma/v1/lte/${networkname}"
}
nw_cert() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/ipsec/root_cert"
}
gw_all() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/gateways"
}
gw_one() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/gateways/${gwname}"
}
eb_all() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/enodebs"
}
eb_one() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/enodebs/${serial}"
}
eb_cert() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/enodebs/${serial}/ipsec/certificate"
}
eb_key() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/enodebs/${serial}/ipsec/priv_key"
}
eb_regen() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/enodebs/${serial}/ipsec/regenerate_certificate"
}
apn_all() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/apns"
}
apn_one() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/apns/${apnname}"
}
sub_all() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/subscribers"
}
sub_one() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/subscribers/${imsi}"
}
tenants_all() {
    url="https://${orcurl}/magma/v1/tenants"
}
tier_all() {
    url="https://${orcurl}/magma/v1/networks/${networkname}/tiers"
}

set_nw_to_vlan() {
    url="https://${orcurl}/magma/v1/lte/${networkname}"
    getn
    newdata=$(echo "$newdata" | jq '.cellular.epc.mobility.enable_multi_apn_ip_allocation = true | .cellular.epc.mobility.ip_allocation_mode = "DHCP_BROADCAST"')
    put
}
set_nw_to_nat() {
    url="https://${orcurl}/magma/v1/lte/${networkname}"
    getn
    newdata=$(echo "$newdata" | jq '.cellular.epc.mobility.enable_multi_apn_ip_allocation = false | .cellular.epc.mobility.ip_allocation_mode = "NAT"')
    put
}
set_vlan_gw_constants() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/gateways/${gwname}"
    getn
    newdata=$(echo "$newdata" | jq '.cellular.epc.nat_enabled = false | .cellular.epc.mesh_mgr_allocation_subnet = "192.168.202.0/24"' )
    newdata=$(echo "$newdata" | jq '.apn_resources.MeshBackhaul = {"apn_name" : "MeshBackhaul", "gateway_ip" : "192.168.202.1", "gateway_mac" : "0c:0c:0c:0c:0c:0c", id: "myagw-MeshBackhaul", "vlan_id" : 202 }')
    newdata=$(echo "$newdata" | jq '.apn_resources.testapn = {"apn_name" : "testapn", "gateway_ip" : "192.168.200.2", "gateway_mac" : "52:54:00:7a:74:a3", id: "myagw-testapn", "vlan_id" : 200, "local_ip": "192.168.200.10/24" }')
}
set_nat_gw_constants() {
    url="https://${orcurl}/magma/v1/lte/${networkname}/gateways/${gwname}"
    getn
    newdata=$(echo "$newdata" | jq 'del(.apn_resources)')
    newdata=$(echo "$newdata" | jq '.cellular.epc.nat_enabled = true | del(.cellular.epc.mesh_mgr_allocation_subnet) | del(.cellular.epc.sgi_management_iface_vlan)')
}
set_mgmt_dhcp() {
    newdata=$(echo "$newdata" | jq 'del(.cellular.epc.sgi_management_iface_mode) | del(.cellular.epc.sgi_management_iface_static_ip) | del(.cellular.epc.sgi_management_iface_gw) | del(.cellular.epc.sgi_management_iface_dns_primary) | del(.cellular.epc.sgi_management_iface_dns_secondary) | del(.cellular.epc.sgi_management_iface_vlan)')
}
set_mgmt_native_vlan() {
    newdata=$(echo "$newdata" | jq '.cellular.epc.sgi_management_iface_mode = "static" | .cellular.epc.sgi_management_iface_static_ip = "192.168.122.90/24" | .cellular.epc.sgi_management_iface_gw = "192.168.122.1" | .cellular.epc.sgi_management_iface_dns_primary = "8.8.4.4" | .cellular.epc.sgi_management_iface_dns_secondary = "8.8.8.8" | del(.cellular.epc.sgi_management_iface_vlan)')
}
set_mgmt_vlan_203() {
    newdata=$(echo "$newdata" | jq '.cellular.epc.sgi_management_iface_mode = "static" | .cellular.epc.sgi_management_iface_static_ip = "192.168.203.5/24" | .cellular.epc.sgi_management_iface_gw = "192.168.203.1" | .cellular.epc.sgi_management_iface_dns_primary = "8.8.4.4" | .cellular.epc.sgi_management_iface_dns_secondary = "8.8.8.8" | .cellular.epc.sgi_management_iface_vlan = "203"')
}
set_testapn2_vlan_203_normal() {
    newdata=$(echo "$newdata" | jq '.apn_resources.testapn2 = {"apn_name" : "testapn2", "gateway_ip" : "192.168.203.2", "gateway_mac" : "52:54:00:7a:74:a3", id: "myagw-testapn2", "vlan_id" : 203, "local_ip": "192.168.203.10/24" }')
}
set_testapn2_vlan_203_along_with_mgmt() {
    newdata=$(echo "$newdata" | jq '.apn_resources.testapn2 = {"apn_name" : "testapn2", "gateway_ip" : "192.168.203.1", "gateway_mac" : "52:54:00:7a:74:a3", id: "myagw-testapn2", "vlan_id" : 203 }')
}
set_testapn2_vlan_0() {
    newdata=$(echo "$newdata" | jq '.apn_resources.testapn2 = {"apn_name" : "testapn2", "gateway_ip" : "192.168.122.1", "gateway_mac" : "52:54:00:60:49:9c", id: "myagw-testapn2", "vlan_id" : 0 }')
}

set_vlan_agw_mgmt_0_apn_diff() {
    set_nw_to_vlan
    set_vlan_gw_constants
    set_mgmt_native_vlan
    set_testapn2_vlan_203_normal
    put
}
set_vlan_agw_mgmt_0_apn_same_as_mgmt() {
    set_nw_to_vlan
    set_vlan_gw_constants
    set_mgmt_native_vlan
    set_testapn2_vlan_0
    put
}
set_vlan_agw_mgmt_203() {
    set_nw_to_vlan
    set_vlan_gw_constants
    set_mgmt_vlan_203
    set_testapn2_vlan_203_along_with_mgmt
    put
}

set_nat_agw_mgmt_static() {
    set_nw_to_nat
    set_nat_gw_constants
    set_mgmt_native_vlan
    put
}
set_nat_agw_mgmt_dhcp() {
    set_nw_to_nat
    set_nat_gw_constants
    set_mgmt_dhcp
    put
}

update_s1_ip() {
    ip="$1"
    newdata=$(echo "$newdata" | jq '.cellular.epc.s1_iface_static_ip = "'"$ip"'"' )
}
update_mmgr_anchor() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.epc.mesh_mgr_anchor_subnet = "'"$ipnet"'" ')
}
update_cobalt_assign() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.epc.cobalt_assignment_subnet = "'"$ipnet"'" ')
}
update_ueip() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.epc.ip_block = "'"$ipnet"'"')
}
update_mmgr_allocation() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.epc.mesh_mgr_allocation_subnet = "'"$ipnet"'"' )
}
update_ipsec_ap_net() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.ipsec.enodeb_ip_subnet = "'"$ipnet"'"')
}
update_ipsec_mmeip() {
    ipnet="$1"
    newdata=$(echo "$newdata" | jq '.cellular.ipsec.mme_local_ip = "'"$ipnet"'"')
}

#### END ORC FNS BLOCK

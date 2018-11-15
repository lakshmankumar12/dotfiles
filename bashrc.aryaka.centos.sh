alias python27="$HOME/install/python27/bin/python2.7"
alias python2.7="$HOME/install/python27/bin/python2.7"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/install/clang/local/lib:$HOME/install/clang/local/lib.hide:$HOME/install/mosh/mosh_build/lib"
export PERL5LIB="$HOME/install/perl/lib"

host=$(hostname)
if [ "$host" == "mforge3.corp.aryaka.com" ] ; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/home/lakshman_narayanan/missing_libs
fi

alias gwsa='cd $HOME/ws/git-dir-for-svn/git_asn'
alias gwss='cd $HOME/ws/git-dir-for-svn/git_static/il3'
alias gwsi='cd $HOME/ws/git-dir-for-svn/git_import'

alias mil3='cd $HOME/ws/il3-scripts/il3_work_repo/il3/'
alias mil3b='cd $HOME/ws/il3-scripts/il3_work_repo/il3/bin'
alias mil3x='cd $HOME/ws/il3-scripts/il3_work_repo/il3/xml.tim'

alias il3='cd /usr/local/il3/'
alias il3x='cd /usr/local/il3/xml'
alias il3b='cd /usr/local/il3/bin'

alias m3w='cd /usr/home/lakshman_narayanan/mforge3_ws'
alias m3h='cd /usr/home/lakshman_narayanan/'
alias m3k='cd /usr/home/lakshman_narayanan/rpmbuild.anap_kernel'

export MYIL3=/home/lakshman_narayanan/ws/il3-scripts/il3_work_repo/il3/xml.tim/
export TIMIL3=/home/tpandre/il3.xml/

alias issh='TERM=xterm /home/lakshman_narayanan/gitlab/aryaka-scripts/dirty_anap_ssh.sh'

alias t='cd $HOME/jira/TEMP ; ls -lrt'
alias bk='cd $HOME/backup ; ls -lrt'
alias ft='cd $HOME/jira/FEATURES ; ls'
alias feat='cd $HOME/jira/FEATURES ; ls'
alias tp='cd $HOME/tmp ; ls -lrt'

#blue-ish
export ETANCOLOR=colour202
#light-blue-ish
export ECLIENTCOLOR=colour88
#orange-ish
export WTANCOLOR=colour105
#reddish
export WCLIENTCOLOR=colour38

getnexthotfix()
{
    HOTFIXNEXT=$HOME/.hotfixnext
    if [ ! -f "${HOTFIXNEXT}" ] ; then
        echo 0 > ${HOTFIXNEXT}
    fi
    old=$(cat ${HOTFIXNEXT})
    new=$(expr $old + 1)
    echo $new > ${HOTFIXNEXT}
    echo -n $new
}

mkall()
{
  if [ ! -d acehw ] ; then
      echo "Please run from svn root"
      return
  fi
  if [ -n "$1" ] && [ "$1" = "--new" ] ; then
    hotfix_string=LAKSHMAN_$(getnexthotfix)
    echo "${hotfix_string}" > ../.hotfix_string
    echo "Using NEW hotfix_string:$hotfix_string"
    shift 1
  else
    if [ ! -f ../.hotfix_string  ] ; then
      echo "No ../.hotfix_string .. Do a --new mkall"
      return
    fi
    echo "Using existing hotfix_string:$(cat ../.hotfix_string)"
  fi
  if [ -n "$ANAPS_SET" ] ; then
      echo_color red "Hey you have externaly set ANAPS to $ANAPS_SET. So using that"
      ANAPS_IN=$ANAP_SET
  else
      ANAPS_IN=ace2
  fi
  if [ -n "$BUILDINFO_SET" ] ; then
      echo_color green "You have externally set BUILDINFO_SET"
      BUILDINFO_IN=build
  else
      echo "Skipping build info"
      BUILDINFO_IN=skip
  fi
  if [ -n "$SKIP_POP" ] ; then
      echo_color red "You have chosen to skip pop"
      POP_TARGET=()
  else
      POP_TARGET=(pop pop-release)
      echo supplying "${POP_TARGET[@]}"
  fi
  nohup make J=8 ANAPS=$ANAPS_IN SYMBOLS_RPM=false anap-release "${POP_TARGET[@]}" RELEASE=optimized BUILDINFO=$BUILDINFO_IN HOTFIX=$(cat ../.hotfix_string) 2>&1 > make_op &
  pid=$!
  echo -e "You can \ntail -f $(pwd)/make_op\n to watch progress. make pid is $pid"
  python27 ~/bin/make_progress.py $(pwd)/make_op $(basename $(pwd)) $pid
}
alias mkalln='BUILDINFO_SET=build mkall --new'
alias mkallo='BUILDINFO_SET= mkall'
alias mkalloa='BUILDINFO_SET= SKIP_POP=1 mkall'
alias mkalle='BUILDINFO_SET=build mkall'

mkanap()
{
  go
  nohup make J=8 ANAPS=ace2 SYMBOLS_RPM=false anap-release RELEASE=optimized HOTFIX=LAKSHMAN_$(getnexthotfix) 2>&1 | tee make_op
}

mkrpm()
{
  go ah
  if [[ "$1" = "sym" ]] ; then
      echo "Making with symbols"
      sym=true
  else
      echo "Making without symbols"
      sym=false
  fi
  make J=8 ANAPS=ace2 SYMBOLS_RPM=$sym anap-release  HOTFIX=$(cat ../../.hotfix_string)
}
alias mkrpms="mkrpm sym"


mkplain()
{
  nohup make J=8 PLATFORM=ace2 RELEASE=noopt 2>&1 | wrap_make_error.py ~/tmp/errors
}

mkplainpop()
{
  nohup make J=8 PLATFORM=pop RELEASE=noopt 2>&1 | wrap_make_error.py ~/tmp/errors
}

export PATH="$HOME/install/rtags/rtags-2.10-install/wrap-bin:$PATH"

#alias gcomm='if [ -z "$(svn diff)" ]; then git commit -am "$(/home/lakshman_narayanan/gitlab/aryaka-new-clone/get_svn_commit_info.py)" ; else echo "svn diff isnt empty" ; fi'

function gcomm() {
    if [ ! -d "acehw" ]; then
        echo "Please run this from svn root"
        return
    fi
    if [ -n "$(svn diff)" ]; then
        echo "svn diff isnt empty"
        return;
    fi
    if [ -n "$(git newfiles)" ]; then
        echo "some new files"
        git newfiles
        return;
    fi
    git commit -am "$(/home/lakshman_narayanan/gitlab/aryaka-new-clone/get_svn_commit_info.py)"
}

function timnightly() {
  curr_host=$(hostname)
  if [[ $curr_host != *"antares"*  ]] ; then
    echo "Not in antares .. ssh antares first"
    return
  fi
  if [ -z "$1" ] ; then
    repo="r180"
  else
    repo=$1
  fi
  cd /usr/home/tpandre/asn/nightly
  export SVNGITROOT=$(pwd)
  export SVNBRANCH=$repo
}

function nly() {
    python27 /home/lakshman_narayanan/gitlab/aryaka-scripts/gotoReleaseFolder.py $@
    if [ $? -eq 0 ] ; then
        cd $(cat ~/tmp/nightly_choice)
        ls
    fi
}
alias nlyl="nly --latest"
alias nlyb="nly --brfolder"
alias nlya="nly --anap"
alias nlyal="nly --anap --latest"

function archiveroot() {
    if [ -z "$1" ]; then
        echo "usage: archiveroot <branch>"
        return
    fi
    branch=$1
    dest="/home/build/release/archive/$branch/el6_builds"
    if [ ! -d $dest ] ; then
        echo "Dir $dest doesn't exist"
        return
    fi
    cd $dest
}

function archive() {
    if [ -z "$1" ]; then
        echo "usage: archive <branch> <anap|pop> [<number,def:latest]"
        return
    fi
    branch=$1
    shift
    if [ "$branch" == "ask" ] ; then
        branch=$(\ls -t /home/build/release/archive | fzf-tmux --exact)
    fi
    if [ -z "$1" ]; then
        archiveroot $branch
        return
    fi
    where=$1
    shift
    if [ -z "$1" ]; then
        dir=latest
    elif [ "$1" == "ask" ]; then
        dir=$(\ls -t /home/build/release/archive/$branch/el6_builds | fzf-tmux --exact)
    else
        dir=$1
    fi
    dest="/home/build/release/archive/$branch/el6_builds/$dir/$where/install"
    if [ ! -d $dest ] ; then
        echo "Dir $dest doesn't exist"
        return
    fi
    cd $dest
}

function svnsafeup() {
    if [ ! -d acehw ]; then
        echo "Please run this from svn root"
        return
    fi
    svndiff=$(svn diff)
    if [ -n "$svndiff" ] ; then
        echo "svndiff is not empty.. bailing out"
        return
    fi
    svndiff=$(cd import ; svn diff)
    if [ -n "$svndiff" ] ; then
        echo "import svndiff is not empty.. bailing out"
        return
    fi
    svn up
}


function svnsafecommit() {
    if [ -d acehw  -o -d rump  ] ; then
        /bin/true
    else
        echo "Please run this from svn root"
        return
    fi
    if [ -z "$1"  ] ; then
        echo "Supply commit message"
        return
    fi
    if [ -n "$(git newfiles)" ] ; then
        echo "There are new files: $(git newfiles). Please svn add them first"
        return
    fi
    echo "Files to be commited:"
    svndiffjustfiles
    echo "Your commit message:"
    echo "$1"
    echo "---"
    read "yn?Continue?"
    case $yn in
        [Yy]* ) ;;
        * ) echo "Aborting.." ; return ;;
    esac
    svn commit -m "$1"
}

rpmname() {
  \ls -rt *.rpm* | grep -v symbols | tail -n 1
}

rpmver() {
  rpm -q -i -p $(\ls -rt | tail -n 1 ) | grep Version | awk ' { print $3 } '
}

setwthis() {
    export SVNGITROOT="$(pwd)"
    echo "SVNGITROOT set to $(pwd)"
}

setw() {
  shiftclone.py
  if [ "$?" -eq "0" -a -f "$HOME/.shift_clone_result" ] ; then
    export SVNGITROOT="$(cat $HOME/.shift_clone_result)"
    cd "$SVNGITROOT"
  fi
  if [ -n "$1" ] ; then
    go
  fi
}


go () {
  if [ -z "$SVNGITROOT" ] ; then
    echo "SVNGITROOT not set.. Trying to guess by git root"
    gr
    echo "Its now: $SVNGITROOT"
  else
    if [[ $(pwd) != *"$SVNGITROOT"* ]] ; then
      echo "pwd:$(pwd) doesn't contain SVNGITROOT: $SVNGITROOT"
      return
    fi
  fi
  if [ -n "$1" ] ; then
     choice="$1"
  else
     choice="."
  fi
  tgt_dir="$SVNGITROOT"
  if [ -f "${tgt_dir}/.branch_name" ] ; then
    tgt_dir="${tgt_dir}/$(cat ${tgt_dir}/.branch_name)"
  elif [ -n "${tgt_dir}/$SVNBRANCH" ] ; then
    tgt_dir="${tgt_dir}/$SVNBRANCH"
  else
    echo "Neither .branch_name nor SVNBRANCH is set"
    return
  fi
  case $choice in
    ar)
      tgt_dir="${tgt_dir}/build.el6/ace2/anap_root"
      ;;
    ai)
      tgt_dir="${tgt_dir}/build.el6/anap/install"
      ;;
    pi)
      tgt_dir="${tgt_dir}/build.el6/pop/install"
      ;;
    b)
      tgt_dir="${tgt_dir}/build.el6"
      ;;
    bab)
      tgt_dir="${tgt_dir}/build.el6/ace2/bin"
      ;;
    bao)
      tgt_dir="${tgt_dir}/build.el6/ace2/obj"
      ;;
    bpb)
      tgt_dir="${tgt_dir}/build.el6/pop/bin"
      ;;
    bpo)
      tgt_dir="${tgt_dir}/build.el6/pop/obj"
      ;;
    ar7)
      tgt_dir="${tgt_dir}/build.el7/ace2/anap_root"
      ;;
    ai7)
      tgt_dir="${tgt_dir}/build.el7/anap/install"
      ;;
    pi7)
      tgt_dir="${tgt_dir}/build.el7/pop/install"
      ;;
    b7)
      tgt_dir="${tgt_dir}/build.el7"
      ;;
    bab7)
      tgt_dir="${tgt_dir}/build.el7/ace2/bin"
      ;;
    bao7)
      tgt_dir="${tgt_dir}/build.el7/ace2/obj"
      ;;
    bpb7)
      tgt_dir="${tgt_dir}/build.el7/pop/bin"
      ;;
    bpo7)
      tgt_dir="${tgt_dir}/build.el7/pop/obj"
      ;;
    gr)
      tgt_dir="${tgt_dir}/../"
      ;;
    asn)
      tgt_dir="${tgt_dir}/acehw/system/opt/aryaka/asn/bin"
      ;;
    bin)
      tgt_dir="${tgt_dir}/acehw/system/opt/aryaka/asn/bin"
      ;;
    am)
      tgt_dir="${tgt_dir}/acehw/src/acemon"
      ;;
    rse)
      tgt_dir="${tgt_dir}/acehw/src/rse"
      ;;
    ah)
      tgt_dir="${tgt_dir}/acehw"
      ;;
    ac)
      tgt_dir="${tgt_dir}/acehw/acecore"
      ;;
    ak)
      tgt_dir="${tgt_dir}/acehw/acecore/kernel"
      ;;
    pns)
      tgt_dir="${tgt_dir}/pns_ni"
      ;;
    cs)
      tgt_dir="${tgt_dir}/control/schema"
      ;;
    3p)
      tgt_dir="${tgt_dir}/patches/kernel-3.10.0-693"
      ;;
    2p)
      tgt_dir="${tgt_dir}/patches/kernel-2.6.32-431.11.2.el6"
      ;;
    *)
      tgt_dir="${tgt_dir}/$choice"
  esac
  cd "$tgt_dir"
}

scpfileanapfromgr()
{
    evalVariablePresence ANAP verbose || return 1
    if [ -z "$1" ]; then
        echo "supply bin to scp"
        return 1
    fi
    echo "scping to ANAP: $ANAP"
    ( go .. ; /usr/local/il3/bin/il3scp "$1"  ${ANAP}:/tmp )
}

scpbinfileanap()
{
    evalVariablePresence ANAP verbose || return 1
    if [ -z "$1" ]; then
        echo "supply bin to scp"
        return 1
    fi
    echo "scping to ANAP: $ANAP"
    ( go bab ; /usr/local/il3/bin/il3scp "$1"  ${ANAP}:/tmp )
}

alias scprse='scpbinfileanap rse'
alias scpam='scpbinfileanap acemon'
alias scppns='scpbinfileanap pns_ni'

scpschemafileanap()
{
    evalVariablePresence ANAP verbose || return 1
    if [ -z "$1" ]; then
        echo "supply schema to scp"
        return 1
    fi
    echo "scping to ANAP: $ANAP"
    ( go control/schema ; /usr/local/il3/bin/il3scp "$1"  ${ANAP}:/tmp )
}

scpsourcebinfileanap()
{
    evalVariablePresence ANAP verbose || return 1
    if [ -z "$1" ]; then
        echo "supply bin to scp"
        return 1
    fi
    echo "scping to ANAP: $ANAP"
    ( go bin ; /usr/local/il3/bin/il3scp "$1"  ${ANAP}:/tmp )
}

alias scprc='scpschemafileanap config_schema.xml'
alias scpdprm='scpschemafileanap dprm_config_schema.xml'
alias scpstatic='scpschemafileanap static_routing_config_schema.xml'


listallpty()
{
    a=(01 02 03 04)
    for i in ${a[@]} ; do listtmuxpanes "$i-" ; done | sort -t\| -k6
}

alias reset_to='$HOME/bin/update_tag.py -r'

tmuxcolorset()
{
    tmux set-window-option -t $1 window-status-bg $2
    tmux set-window-option -t $1 window-status-fg black
}

gotoMusicPane() {
    #we will over-ride this to ary-scripts
    gotoTmuxPane 01-scripts 3 0
}

loadThisBuildNpop() {
    if [ -z "$NUM" ]; then
        echo "Please set NUM"
        return
    fi
    if [ -z "$ANAP" ] ; then
        echo "Please set ANAP"
        return
    fi
    echo "Using NUM: $NUM and ANAP: $ANAP"
    p=$(pwd)
    base1=$(basename $p)
    if [ "$base1" != "install" ]; then
        echo "We dont seem to be in install folder. Base:$base1"
        return
    fi
    p=$(dirname $p)
    base2=$(basename $p)
    if [ "$base2" != "pop" ]; then
        echo "We dont seem to be in pop/install folder. Base:$base2/$base1"
        return
    fi
    if [ ! -d ../../anap/install ] ; then
        echo "There doesn't seem to be a anap install folder "
        return
    fi
    cd ../../anap/install
    if [ ! -f $(rpmname) ] ; then
        echo "Couldn't spot ../../anap/install/$(rpmname)"
        cd ../../pop/install
        return;
    fi
    cd ../../pop/install
    /usr/local/il3/bin/il3setver -v $(rpmver) -n ${NUM}
    a=("ntan" "npan")
    for i in ${a[@]} ; do
        il3ssh $i rpm -ivh --nodeps --force $(pwd)/$(rpmname)
    done
    il3ssh ntan /home/lakshman_narayanan/ws/il3-scripts/il3_work_repo/il3/bin/il3update_for_ntan
    echo "Updated in ntan"
    sleep 2
    cd ../../anap/install
    /usr/local/il3/bin/aceupgrade -l $(rpmname) ${ANAP}
    cd ../../pop/install
}
alias lbnpop=loadThisBuildNpop


loadThisBuildEWPop()
{
    if [ -z "$NUM" ]; then
        echo "Please set NUM"
        return
    fi
    if [ -z "$ANAP" ] ; then
        echo "Please set ANAP"
        return
    fi
    echo "Using NUM: $NUM and ANAP: $ANAP"
    p=$(pwd)
    base1=$(basename $p)
    if [ "$base1" != "install" ]; then
        echo "We dont seem to be in install folder. Base:$base1"
        return
    fi
    p=$(dirname $p)
    base2=$(basename $p)
    if [ "$base2" != "pop" ]; then
        echo "We dont seem to be in pop/install folder. Base:$base2/$base1"
        return
    fi
    /usr/local/il3/bin/il3setver -v $(rpmver) -n ${NUM}
    /usr/local/il3/bin/il3insrpm $(rpmname)
    /usr/local/il3/bin/il3push
    cd ../../anap/install
    /usr/local/il3/bin/aceupgrade -l $(rpmname) ${ANAP}
}

anapload()
{
    if [ -n "$ANAP" ] ; then
        echo "Using ANAP: $ANAP"
        ( go ai && /usr/local/il3/bin/aceupgrade -l $(rpmname) ${ANAP} )
    else
        echo "Set ANAP"
    fi
}
alias loadanap=anapload

svnlogauthor()
{
    if [ -z "$1" ] ; then
        echo "Please supply username"
        return
    fi
    author=$1
    shift
    svn log "$@" | sed -n '/'"$author"'/,/-----$/ p'
}

svnlogme()
{
    svnlogauthor "lakshman" $@
}

getAceLogFromAnap()
{
    evalVariablePresence ANAP verbose || return 1
    il3scp $ANAP:/var/log/ace.log log
    number=$(grep -n 'rsyslogd.*start' log | tail -n 1 | cut -d: -f1); number=$(expr $number - 1) ; echo $number
    sed -i -e "1,${number}d" -e 's/[[:space:]]\+$//' log
    vi log
}

getRseLogFromAnap()
{
    evalVariablePresence ANAP verbose || return 1
    il3scp $ANAP:/var/aryaka/nexus/rse/rse.log log
    vi log
}

getPnsLogFromAnap()
{
    evalVariablePresence ANAP verbose || return 1
    il3scp $ANAP:/var/aryaka/nexus/pns_ni/pns.log log
    vi log
}

getLatestCrashFileFromAnap()
{
    if [ -z "$ANAP" ] ; then
        echo "Set ANAP"
        return
    else
        echo "Using ANAP: $ANAP"
    fi
    file=$(il3ssh $ANAP ls -1rt '/var/core/*.gz' | tail -n 1 | sed 's/\r//')
    if [[ $file = *"gz"*  ]] ; then
        echo "Extracting: $file"
    else
        echo "Not finding a .gz file in anap:$ANAP"
        return 1
    fi
    il3scp $ANAP:${file} .
    file=$(basename ${file})
    tar xf ${file}
    dir=$(tar tf ${file} | head -n 1)
    echo "File: ${file}, dir: ${dir}"
    cd $dir
    ls
}

scpfrommac()
{
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $(cat /home/lakshman_narayanan/.mymacport) lakshman.narayanan@$(cat /home/lakshman_narayanan/.mymacip):"'"$1"'" .
}

scpfrommacdn()
{
    scpfrommac /Users/lakshman.narayanan/Downloads/"'"$1"'"
}

scptomac()
{
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $(cat /home/lakshman_narayanan/.mymacport) "$@" lakshman.narayanan@$(cat /home/lakshman_narayanan/.mymacip):/Users/lakshman.narayanan/Downloads/
}

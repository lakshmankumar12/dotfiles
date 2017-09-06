alias python27="$HOME/install/python27/bin/python2.7"
alias python2.7="$HOME/install/python27/bin/python2.7"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/install/clang/local/lib:$HOME/install/clang/local/lib.hide:$HOME/install/mosh/mosh_build/lib"
export PERL5LIB="$HOME/install/perl/lib"

alias gwsa='cd $HOME/ws/git-dir-for-svn/git_asn'
alias gwss='cd $HOME/ws/git-dir-for-svn/git_static/il3'
alias gwsi='cd $HOME/ws/git-dir-for-svn/git_import'

alias mil3='cd $HOME/ws/il3-scripts/il3_work_repo/il3/'
alias mil3b='cd $HOME/ws/il3-scripts/il3_work_repo/il3/bin'
alias mil3x='cd $HOME/ws/il3-scripts/il3_work_repo/il3/xml.tim'

alias il3='cd /usr/local/il3/'
alias il3x='cd /usr/local/il3/xml'
alias il3b='cd /usr/local/il3/bin'

export MYIL3=/home/lakshman_narayanan/ws/il3-scripts/il3_work_repo/il3/xml.tim/
export TIMIL3=/home/tpandre/il3.xml/

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
  go
  nohup make J=8 ANAPS=ace2 SYMBOLS_RPM=false anap-release pop pop-release RELEASE=optimized HOTFIX=LAKSHMAN_$(getnexthotfix) 2>&1 > make_op &
  pid=$!
  echo -e "You can \ntail -f $(pwd)/make_op\n to watch progress. make pid is $pid"
  python27 ~/bin/make_progress.py $(pwd)/make_op $(basename $(pwd)) $pid
}

mkanap()
{
  go
  nohup make J=8 ANAPS=ace2 SYMBOLS_RPM=false anap-release RELEASE=optimized HOTFIX=LAKSHMAN_$(getnexthotfix) 2>&1 | tee make_op
}


mkplain()
{
  nohup make J=8 PLATFORM=ace2 2>&1 | wrap_make_error.py /tmp/errors
}

mkplainpop()
{
  nohup make J=8 PLATFORM=pop 2>&1 | wrap_make_error.py /tmp/errors
}

export PATH="$HOME/install/rtags/rtags-2.10-install/wrap-bin:$PATH"

alias gcomm='git commit -am "$(/home/lakshman_narayanan/gitlab/aryaka-new-clone/get_svn_commit_info.py)"'
function nightly() {
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
  cd /usr/antares2/nightly.el6
  export SVNGITROOT=$(pwd)
  export SVNBRANCH=$repo
}

rpmname() {
  \ls -rt | grep -v symbols | tail -n 1
}

rpmver() {
  rpm -q -i -p $(\ls -rt | tail -n 1 ) | grep Version | awk ' { print $3 } '
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
  cd $SVNGITROOT
  if [ -f .branch_name ] ; then
    cd $(cat .branch_name)
  elif [ -n "$SVNBRANCH" ] ; then
    cd "$SVNBRANCH"
  else
    echo "Neigher .branch_name nor SVNBRANCH is set"
    return
  fi
  case $choice in
    ar)
      cd build.el6/ace2/anap_root
      ;;
    ai)
      cd build.el6/anap/install
      ;;
    pi)
      cd build.el6/pop/install
      ;;
    b)
      cd build.el6
      ;;
    gr)
      cd ../
      ;;
    am)
      cd acehw/src/acemon
      ;;
    ah)
      cd acehw
      ;;
    pns)
      cd pns_ni
      ;;
    cs)
      cd control/schema
      ;;
    *)
      cd $choice
  esac
}

listallpty()
{
    a=(01 02 03 04)
    for i in ${a[@]} ; do listtmuxpanes "$i-" ; done | sort -t\| -k5
}

alias reset_to='$HOME/bin/update_tag.py -r'

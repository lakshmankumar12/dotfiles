alias python27="$HOME/install/python27/bin/python2.7"
alias python2.7="$HOME/install/python27/bin/python2.7"
export PYTHONPATH="$HOME/local/lib/python2.6/site-packages:$HOME/install/python27/lib/python2.7/site-packages"
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

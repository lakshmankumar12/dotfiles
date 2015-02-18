set tabstop=4
set shiftwidth=2
set sidescroll=1
set grepprg=fgrep\ -n
set term=xterm
set mouse=a
set previewheight=20
set ruler
set nocp
set history=100
filetype plugin on


map ~mai i#include<stdio.h><CR><CR>int main(int argc,char *argv[],char *envp[])<CR>{<CR><CR>}<CR><Esc>kka<Tab>
map ~cmai i#include<iostream><CR><CR>using namespace std;<CR><CR>int main(int argc,char *argv[],char *envp[])<CR>{<CR><CR>return 0;<CR>}<CR><Esc>kka<Tab>
map ~typ itypedef struct<CR>{<CR><CR>}  ;<Esc>hi

set incsearch
set hlsearch
set nowrap
set expandtab
set showcmd
set ai
set cindent

if !has("gui_running")
    set t_Co=8
    set t_Sf=^[[3%p1%dm
    set t_Sb=^[[4%p1%dm
endif

syntax enable

highlight search term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
highlight comment term=underline ctermfg=6 guifg=DarkCyan

map + <Esc>:cn<CR>
map - <Esc>:cp<CR>

au FileType make setlocal noexpandtab

"for the ShowFunc.vim plugin.
let g:showfuncctagsbin = "/home/lnara002/software/ctags/ctags-5.8/postinstall/bin/ctags"
let g:ShowFuncScanType = "current"

"for the ctags.vim plugin.
let g:ctags_path="/home/lnara002/software/ctags/ctags-5.8/postinstall/bin/ctags"
let g:ctags_statusline=1
let g:ctags_title=0
let generate_tags=1

set bg=dark

function! DumpToClipBoard()
  "call writefile(split(@","\n"), '/dev/clipboard')
  call system("xsel -i -b", getreg("\""))
  call system("xsel -i -b", getreg("\""))
endfunction

function! Panosgrep(grepMatter)
  echo "grepping " . a:grepMatter
  call system("panosgrep panos ". a:grepMatter)
  cf grepOp
endfunction

function! PanosAskGrep(grepMatter)
  let s:matter = input("what to grep:",a:grepMatter)
  let s:directory = input("dir:","lte_")
  let s:ignorecase = input("ic:","n")
  let s:ic = ""
  if s:ignorecase == "y"
    s:ic = "-i "
  endif 
  let s:cmd="panosgrep " . s:ic . "'" . s:directory . "' " . s:matter
  echo "Running " . s:cmd
  call system(s:cmd)
  cf grepOp
endfunction 


cmap p$$<CR> call DumpToClipBoard()<CR>
map ~clip :call DumpToClipBoard()<CR>
map ~cip :call DumpToClipBoard()<CR>
map <F2> :call DumpToClipBoard()<CR>
map <F3> :call PanosAskGrep(expand("<cword>"))<CR>
map <F5> :call PanosAskGrep("")<CR>

vmap <C-c> y:call DumpToClipBoard()<CR> 

let @r="lte_common|lte_cpm|lte_mgmt|lte_mscp|lte_pmip|mc_red"

set csprg='/home/lnara002/software/cscope/cscope-15.8a/postinstall/bin/cscope'


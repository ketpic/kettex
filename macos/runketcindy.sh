#!/bin/bash
## KeTTeX.app internal starter script

## bundle realpath command in Resources folder
RESOURCESDIR=$(cd $(dirname $0); pwd)
TLPATH=${RESOURCESDIR}/../../texlive/bin/x86_64-darwin
export PATH=${TLPATH}:/usr/bin:/bin:/usr/sbin:/sbin

cat<<EOF

KeTTeX terminal

This is constructed from the following components:
 * TeX Live
   * uplatex:	$(uplatex --version | head -n 1)
   * dvipdfmx:	$(dvipdfmx --version | head -n 1 | sed -e "s,^This is ,," -e "s,by.*,,")
   * lualatex:	$(lualatex --version | head -n 1)
EOF

## set aliases
alias eng='LANG=C LANGUAGE=C LC_ALL=C'

alias ls='ls -F -G'
alias ll='ls -la -G'
alias la='ls -a -G'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

## restrict logout with Ctrl-d
export IGNOREEOF=25

# end of file

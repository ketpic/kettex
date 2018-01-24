#!/bin/bash
## KeTTeX.app internal starter script

## bundle realpath command in Resources folder
export PATH=$(dirname $0):/usr/bin:/bin:/usr/sbin:/sbin

TLPATH=$(realpath $(dirname $0)/../../texlive/bin/x86_64-darwin)
export PATH=${TLPATH}:${PATH}

## copy KetCindyPlugin.jar to Cinderella2 PlugIns folder
# __cindybin=/Applications/Cinderella2.app/Contents/MacOS/Cinderella2
CINDYPLUG=/Applications/Cinderella2.app/Contents/PlugIns
KetCdyJar=`kpsewhich -format=texmfscripts KetCindyPlugin.jar`
if [ ! -d ${CINDYPLUG} ]
then
    osascript -e "display dialog \"Cannot find Cinderella2 PlugIns folder: ${CINDYPLUG}\""
    exit 1
fi
if [ -z "${KetCdyJar}" ]
then
    osascript -e "display dialog \"Cannot find ${KetCdyJar}!\""
    exit 1
fi
## try to install the jar when cannot find the jar in the plugins folder
if [ ! -f ${CINDYPLUG}/KetCindyPlugin.jar ]
then
    cp -a ${KetCdyJar} ${CINDYPLUG}/ ||:
fi

## output system-wide settings 
KETCINDYSCRIPTS=$(dirname $(kpsewhich -format=texmfscripts setketcindy.txt))
sysdirhead=${CINDYPLUG}/dirhead.txt
if [ ! -f ${sysdirhead} ]; then
    cat<<EOF>${sysdirhead}
PathThead="${TLPATH}/";
Homehead="/Users";
Dirhead="${KETCINDYSCRIPTS}";
setdirectory(Dirhead);
import("setketcindy.txt");
import("ketoutset.txt");
EOF
fi
## not support Scilab as default
# sysdirheadsci=${CINDYPLUG}/dirheadsci.txt
# if [ ! -f ${sysdirheadsci} ]; then
#     cat<<EOF>${sysdirheadsci}
# PathThead="${TLPATH}/";
# Homehead="/Users";
# Dirhead="${KETCINDYSCRIPTS}";
# setdirectory(Dirhead);
# import("setketcindysci.txt");
# import("ketoutset.txt");
# EOF
# fi

## output user-wide settings
userdirhead=${HOME}/ketcindyhead.txt
if [ ! -f ${userdirhead} ]; then
    cat<<EOF>${userdirhead}
Dirfile=gethome()+"/ketcindy";
PathT=PathThead+"uplatex";
Mackc="sh";
// Pathpdf="preview";
// Pathpdf="skim";
EOF
fi

## copy manuals and samples
userketcindydir=${HOME}/ketcindy
if [ ! -d ${userketcindydir} ]; then
    cp -a $(kpsewhich --var-value=TEXMFDIST)/doc/support/ketcindy ${userketcindydir}
    rm -rf ${userketcindydir}/README.TeXLive ${userketcindydir}/source
fi

## Then, now just kick the ketcindy starter script
ketcindy $@ || \
    osascript -e "display dialog \"$(ketcindy $@ 2>&1)\""

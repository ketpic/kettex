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
dirhead=${CINDYPLUG}/dirhead.txt
if [ ! -f ${dirhead} ]; then
    cat<<EOF>${dirhead}
PathThead="${TLPATH}/";
Homehead="/Users";
Dirhead="${KETCINDYSCRIPTS}";
setdirectory(Dirhead);
import("setketcindy.txt");
import("ketoutset.txt");
EOF
fi
dirheadsci=${CINDYPLUG}/dirheadsci.txt
if [ ! -f ${dirhead} ]; then
    cat<<EOF>${dirheadsci}
PathThead="${TLPATH}/";
Homehead="/Users";
Dirhead="${KETCINDYSCRIPTS}";
setdirectory(Dirhead);
import("setketcindysci.txt");
import("ketoutset.txt");
EOF
fi

ketcindy $@ || \
    osascript -e "display dialog \"$(ketcindy $@ 2>&1)\""

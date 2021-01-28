#!/bin/bash -x

set -e

##
## INITIALIZATION
## ==============================

## set temporary KeTTeX root
KETTEXTEMP=${KETTEXTEMP:-$(pwd)/Work}
KETTEXROOT=${KETTEXROOT:-${KETTEXTEMP}/kettex/texlive}
KETTEXAPP=${KETTEXAPP:-${KETTEXTEMP}/kettex/KeTTeX.app}

## set target platform
WITH_WINDOWS=${WITH_WINDOWS:-0}
WITH_LINUX=${WITH_LINUX:-0}
WITH_MACOS=1 ## default: build for Mac OS X
TARGETOS=macos
if [ $(( ${WITH_WINDOWS}+${WITH_LINUX} )) -ge 1 ]; then
   WITH_MACOS=0
   [ ${WITH_WINDOWS} -eq 1 ] && TARGETOS=windows
   [ ${WITH_LINUX} -eq 1 ]   && TARGETOS=linux
fi
KETTEXPKG=KeTTeX-${TARGETOS}-$(date +%Y%m%d)

## set given tlnet repository for TLYY installation
TLNET=${TLNET:-http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz}                # http://texlive.texjp.org/2020/tlnet
## set usual main tlnet repository
MAIN_TLNET=${MAIN_TLNET:-http://mirror.ctan.org/systems/texlive/tlnet} # http://texlive.texjp.org/2020/tlnet

## initialize some environment variables
export LANG=C LANGUAGE=C LC_ALL=C

case $(uname) in
    Darwin)
        export PATH=${KETTEXROOT}/bin/x86_64-darwin:/usr/local/bin:/usr/bin:/bin

        __cp="cp -avf"
        __sed=gsed
        __tar="gtar --owner=0 --group=0"
        __xz="pixz -9 -p4"
        ;;
    Linux)
        export PATH=${KETTEXROOT}/bin/x86_64-linux:/usr/bin:/bin

        __cp="cp -avf"
        __sed=sed
        __tar="tar --owner=0 --group=0"
        __xz="pixz -9 -p4"
        ;;
    *)
        echo unsuported: $(uname)
        exit 1
        ;;
esac

#trap cleanup EXIT
cleanup() {
    set +e
    rm -f install-tl-unx.tar.gz
    rm -rf ${KETTEXROOT}/install-tl-unx
    # rm -rf ${KETTEXTEMP}
}

##
## INSTALLATION
## ==============================

## clean our temporary directory
rm -rf ${KETTEXTEMP} installation.profile install-tl.log

## run TLYY frozen installer with the texlive.profile
mkdir -p ${KETTEXROOT}/install-tl-unx
if [ -f ${TLNET}/install-tl-unx.tar.gz ]; then
    $__cp ${TLNET}/install-tl-unx.tar.gz .
fi
if [ ! -f install-tl-unx.tar.gz ]; then
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
fi
$__tar -C ${KETTEXROOT}/install-tl-unx --strip-components=1 -xf install-tl-unx.tar.gz

## deploy the installation profile texlive.profile for KeTTeX
mkdir -p ${KETTEXROOT}/install-tl-unx
sed -e "s,@@WITH_WINDOWS@@,${WITH_WINDOWS}," \
    -e "s,@@WITH_LINUX@@,${WITH_LINUX}," \
    -e "s,@@TEXDIR@@,${KETTEXROOT}," \
    kettex.profile.in >${KETTEXROOT}/install-tl-unx/texlive.profile

perl ${KETTEXROOT}/install-tl-unx/install-tl \
             --profile ${KETTEXROOT}/install-tl-unx/texlive.profile \
             --repository ${TLNET}

# install ketcindy package
tlmgr install ketcindy

# uninstall some packages to reduce disk space
# tlmgr uninstall jlreq-deluxe

## replace: ${TLNET} -> ${MAIN_TLNET}
$__sed -i -e "s,depend opt_location:${TLNET},depend opt_location:${MAIN_TLNET}," ${KETTEXROOT}/tlpkg/texlive.tlpdb

##
## BUILDING IMAGE ARCHIVE
## ==============================

##
## For Mac OS X, make KeTTeX.app which you can deploy everywhere on your system
## --------------------
if [ $WITH_MACOS -eq 1 ]; then
    $__cp macos/KeTTeX.app ${KETTEXTEMP}/kettex/
    mv ${KETTEXROOT} ${KETTEXAPP}/

    ## make eazy layout of dmg-style installer
    ## drag and drop: KeTTeX.app ===> /Applications/
    (cd ${KETTEXTEMP}/kettex
     ln -s /Applications .
    )

    ## make ULFO-formatted dmg.
    ## You can extract the one on macOS 10.11+ (El Capitan or higher version)
    # hdiutil_encopts="-format UDZO -imagekey zlib-level=9"
    hdiutil_encopts="-format ULFO"  ##<= macOS 10.11+
    hdiutil create -ov -srcfolder ${KETTEXTEMP}/kettex \
            -fs HFS+ ${hdiutil_encopts} \
            -volname "KeTTeX" ${KETTEXPKG}.dmg
    echo $(basename $0): built ${KETTEXPKG}.dmg
else
##
## For other platform (Windows/Linux), make tarball image
## --------------------

    ## dropped x86_64-darwin platform
## # $ tlmgr platform remove x86_64-darwin
## You are running on platform x86_64-darwin, you cannot remove that one!
## tlmgr: action platform returned an error; continuing.
## tlmgr: An error has occurred. See above messages. Exiting.
    ## so, forcely remove the one
    rm -rf ${KETTEXROOT}/bin/x86_64-darwin

    ## For Windows, replace symbolic-linked map file with hard copy respectively
    rm -f ${KETTEXROOT}/texmf-var/fonts/map/dvips/updmap/psfonts.map
    cp -a ${KETTEXROOT}/texmf-var/fonts/map/dvips/updmap/{psfonts_t1,psfonts}.map
    rm -f ${KETTEXROOT}/texmf-var/fonts/map/pdftex/updmap/pdftex.map
    cp -a ${KETTEXROOT}/texmf-var/fonts/map/pdftex/updmap/{pdftex_dl14,pdftex}.map
    ## and check other symbolic-linked files.
    find ${KETTEXROOT} -type l

    ## Finally, build tar+xz image archive and calculate SHA-1 hash of the one
    $__tar -C ${KETTEXTEMP} -cf - kettex | $__xz >${KETTEXPKG}.tar.xz
    echo $(basename $0): built ${KETTEXPKG}.tar.xz
fi

echo $(basename $0): finished

exit

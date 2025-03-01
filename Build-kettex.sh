#!/bin/bash -x
set -euxo pipefail
cd "$(dirname "$0")"

##
## INITIALIZATION
## ==============================

##
KETCINDYLATESTVERZIP=ketcindy-4.5.21_kettex.zip
EMATHLATESTVERZIP=emath-240123_tds.zip

## set temporary KeTTeX root
KETTEXTEMP=${KETTEXTEMP:-$(pwd)/Work}
KETTEXROOT=${KETTEXROOT:-${KETTEXTEMP}/kettex/texlive}
KETTEXAPP=${KETTEXAPP:-${KETTEXTEMP}/kettex/KeTTeX.app}

## set target OS
WITH_WINDOWS=${WITH_WINDOWS:-0}
WITH_LINUX=${WITH_LINUX:-0}
WITH_MACOS=1 ## default: build for macOS
TARGETOS=macos
if [ $(( ${WITH_WINDOWS}+${WITH_LINUX} )) -ge 1 ]; then
   WITH_MACOS=0
   [ ${WITH_WINDOWS} -eq 1 ] && TARGETOS=windows
   [ ${WITH_LINUX} -eq 1 ]   && TARGETOS=linuxfreebsd
fi
KETTEXPKG=KeTTeX-${TARGETOS}-$(date +%Y%m%d)

## set available platform(s) for the target OS
TARGETOS_ARCHS=universal-darwin
case ${TARGETOS} in
    windows)	TARGETOS_ARCHS='windows' ;;
    linuxfreebsd)		TARGETOS_ARCHS='x86_64-linux aarch64-linux amd64-freebsd' ;;
esac

## set given tlnet repository for TLYY installation
TLNET=${TLNET:-http://mirror.ctan.org/systems/texlive/tlnet} # http://texlive.texjp.org/2020/tlnet
## set usual main tlnet repository
MAIN_TLNET=${MAIN_TLNET:-http://mirror.ctan.org/systems/texlive/tlnet} # http://texlive.texjp.org/2020/tlnet


## initialize some environment variables
export LANG=C LANGUAGE=C LC_ALL=C

case $(uname) in
    Darwin)
        export PATH=${KETTEXROOT}/bin/universal-darwin:${KETTEXROOT}/bin/x86_64-darwin:/opt/homebrew//bin:/usr/bin:/bin

        __cp="cp -avf"
        __sed=gsed
        __tar="gtar --owner=0 --group=0"
        __xz="pixz -9 -p4"
        __zstd="pzstd -9 -p4"
        ;;
    Linux)
        export PATH=${KETTEXROOT}/bin/x86_64-linux:/usr/bin:/bin

        __cp="cp -avf"
        __sed=sed
        __tar="tar --owner=0 --group=0"
        __xz="pixz -9 -p4"
        __zstd="pzstd -9 -p4"
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

## deploy the installation profile for KeTTeX
mkdir -p ${KETTEXROOT}/install-tl-unx
$__sed -e "s,@@WITH_WINDOWS@@,${WITH_WINDOWS}," \
       -e "s,@@WITH_LINUX@@,${WITH_LINUX}," \
       -e "s,@@TEXDIR@@,${KETTEXROOT}," \
       kettex.profile.in >${KETTEXROOT}/install-tl-unx/kettex.profile

perl ${KETTEXROOT}/install-tl-unx/install-tl \
             --profile ${KETTEXROOT}/install-tl-unx/kettex.profile \
             --repository ${TLNET}

## drop installer
rm -rf ${KETTEXROOT}/install-tl-unx

# install additional packages
tlmgr install ketcindy \
    algorithms algorithmicx \
    bbold bbold-type1 \
    ebgaramond \
    fontawesome \
    inconsolata \
    mnsymbol \
    physics \
    sourcecodepro sourcesanspro \
    systeme \
    ulem \
    roboto \
    stix2-otf stix2-type1 \
    noto-emoji

# uninstall some packages to reduce disk space
tlmgr uninstall --force \
      $(tlmgr list --only-installed --data 'name' | grep -e 'tex4ht' -e 'make4ht' -e 'tex4ebook' -e 'tlcockpit' -e 'xindy' -e 'xindex') \
    ||:
for platform in windows universal-darwin x86_64-linux aarch64-linux amd64-freebsd; do
    [ -d ${KETTEXROOT}/bin/${platform}/ ] && \
        cd ${KETTEXROOT}/bin/${platform}/ && \
        rm -f ketcindy man httexi htmex htxelatex xindex mk4ht xindy htxetex htlatex xhlatex ht make4ht texindy tlcockpit httex tex4ebook && \
        cd - ||:
done

# install the latest ketcindy
if [ -f ${KETCINDYLATESTVERZIP} ]; then
    tlmgr uninstall --force \
          $(tlmgr list --only-installed --data 'name' | grep -e 'ketcindy') \
        ||:
    unzip ${KETCINDYLATESTVERZIP} -d ${KETTEXROOT}/texmf-dist/
    mktexlsr ${KETTEXROOT}/texmf-dist/

##TODO: windows
    for platform in universal-darwin x86_64-linux aarch64-linux amd64-freebsd; do
        [ -d ${KETTEXROOT}/bin/${platform}/ ] && \
            cd ${KETTEXROOT}/bin/${platform}/ && \
            ln -s ../../texmf-dist/scripts/ketcindy/ketcindy.pl ketcindy && \
            cd - ||:
done


fi

# install the latest emath
if [ -f ${EMATHLATESTVERZIP} ]; then
    unzip ${EMATHLATESTVERZIP} -d ${KETTEXROOT}/texmf-local/
    mktexlsr ${KETTEXROOT}/texmf-local/
fi

## setup suitable texmf.cnf
case ${TARGETOS} in
    macos|linuxfreebsd)
        printf "%s\n" \
               "texmf_casefold_search = 0" \
               >>${KETTEXROOT}/texmf.cnf
        ;;
    windows)
        printf "%s\n" \
               "command_line_encoding.ptex = none       " \
               "command_line_encoding.eptex = none      " \
               "command_line_encoding.platex = none     " \
               "command_line_encoding.platex-dev = none " \
               >>${KETTEXROOT}/texmf.cnf
        ;;
esac
printf "%s\n" \
       "font_mem_size = 16000000 " \
       "font_max = 18000         " \
       "ent_str_size = 2000      " \
       "error_line = 254         " \
       "half_error_line = 238    " \
       "max_print_line = 1048576 " \
       >>${KETTEXROOT}/texmf.cnf

## modify texlive.tlpdb
$__sed -i \
       -e "s,\(depend opt_location:\).*,\1${MAIN_TLNET}," \
       -e "s,\(depend setting_available_architectures:\).*,\1${TARGETOS_ARCHS}," \
       ${KETTEXROOT}/tlpkg/texlive.tlpdb

##
## BUILDING IMAGE ARCHIVE
## ==============================
case ${TARGETOS} in
    ## For macOS, make KeTTeX.app which you can deploy everywhere on your system
    ## --------------------
    macos)
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
        hdiutil_encopts="-fs HFS+ -format ULFO"  ##<= macOS 10.11+ only (fastest, smallest)
        # hdiutil_encopts="-fs APFS -format ULFO"  ##<= macOS 10.13+ only
        # hdiutil_encopts="-fs HFS+ -format ULMO"  ##<= macOS 10.15+ only
        # hdiutil_encopts="-fs APFS -format ULMO"  ##<= macOS 10.15+ only
        hdiutil create -ov -srcfolder ${KETTEXTEMP}/kettex \
                ${hdiutil_encopts} \
                -volname "KeTTeX" ${KETTEXPKG}.dmg
        echo $(basename $0): built ${KETTEXPKG}.dmg
        ;;

    ##
    ## For other platform (Windows/Linux), make tar+zstandard image
    ## --------------------
    windows|linuxfreebsd)
        ## dropped Darwin platforms
        ##     $ tlmgr platform remove x86_64-darwin
        ## You are running on platform x86_64-darwin, you cannot remove that one!
        ##     tlmgr: action platform returned an error; continuing.
        ##     tlmgr: An error has occurred. See above messages. Exiting.
        ## so, forcely remove the one
        rm -rf ${KETTEXROOT}/bin/{universal,x86_64}-darwin

        ## replace symbolic-linked map file with hard copy respectively,
        rm -f ${KETTEXROOT}/texmf-var/fonts/map/dvips/updmap/psfonts.map
        cp -a ${KETTEXROOT}/texmf-var/fonts/map/dvips/updmap/{psfonts_t1,psfonts}.map
        rm -f ${KETTEXROOT}/texmf-var/fonts/map/pdftex/updmap/pdftex.map
        cp -a ${KETTEXROOT}/texmf-var/fonts/map/pdftex/updmap/{pdftex_dl14,pdftex}.map
        ## and check other symbolic-linked files.
        find ${KETTEXROOT} -type l

        if [ $WITH_WINDOWS -eq 1 ]; then
            $__cp windows/kettex.cmd ${KETTEXTEMP}/kettex/
        fi

        ## Finally, build tar+zstd image archive
        $__tar -C ${KETTEXTEMP} -cf - kettex | $__zstd >${KETTEXPKG}.tar.zst
        echo $(basename $0): built ${KETTEXPKG}.tar.zst

        ## for Windows
        if [ $WITH_WINDOWS -eq 1 ]; then
            $__sed -e "s,@@KETTEXPKG@@,${KETTEXPKG}," \
                   windows/kettexinst.cmd.in >${KETTEXTEMP}/kettexinst.cmd
            mv ${KETTEXPKG}.tar.zst ${KETTEXTEMP}/

            ## copy texinstwin.zip
            mkdir -p ${KETTEXTEMP}/texinstwin
            if [ ! -f texinstwin.zip ]; then
                wget http://mirror.ctan.org/systems/win32/w32tex/texinstwin.zip
            fi
            unzip texinstwin.zip -d ${KETTEXTEMP}/texinstwin

            (cd ${KETTEXTEMP}/
             zip -9 -r ${KETTEXPKG}.zip \
                 kettexinst.cmd ${KETTEXPKG}.tar.zst texinstwin/*
            )
            mv ${KETTEXTEMP}/${KETTEXPKG}.zip .
            echo $(basename $0): built ${KETTEXPKG}.zip
        fi
        ;;

    *)
        echo unsuported: $(uname)
        exit 1
        ;;
esac

echo $(basename $0): finished

exit

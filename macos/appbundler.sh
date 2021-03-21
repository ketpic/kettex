#!/bin/bash

set -e

app_name=KeTTeX.app
BUILDROOT=$(dirname $0)

# アプリケーションの作成
rm -rf ${BUILDROOT}/${app_name}
osacompile -o ${BUILDROOT}/${app_name} <<__APPLESCRIPT__
on main()
    try
        tell application "Terminal"
            set appPath to (path to current application as text)
            set appPath to quoted form of (POSIX path of appPath)
            set TLIntelPath to appPath & "texlive/bin/x86_64-darwin"
            set TLArmPath   to appPath & "texlive/bin/universal-darwin"
            do script "export PATH=" & TLArmPath & ":" & TLIntelPath & ":/usr/bin:/bin:/usr/sbin:/sbin; cd \${HOMEDIR};  . " & appPath & "/Contents/Resources/runketcindy.sh"
        end tell
    end try
end main

on run
    main()
end run
__APPLESCRIPT__

## replace default icon with our project icon
[ -f ${BUILDROOT}/${app_name}/Contents/Resources/droplet.icns ] && \
    cp -fva ${BUILDROOT}/../artwork/ketcindy.icns \
       ${BUILDROOT}/${app_name}/Contents/Resources/droplet.icns

[ -f ${BUILDROOT}/${app_name}/Contents/Resources/applet.icns ] && \
    cp -fva ${BUILDROOT}/../artwork/ketcindy.icns \
       ${BUILDROOT}/${app_name}/Contents/Resources/applet.icns

## install internal starter script
cp -fva ${BUILDROOT}/runketcindy.sh \
   ${BUILDROOT}/${app_name}/Contents/Resources/

echo Finished
exit

#!/bin/bash

set -e

app_name=KeTTeX.app
BUILDROOT=$(dirname $0)

# アプリケーションの作成
rm -rf ${BUILDROOT}/${app_name}
osacompile -o ${BUILDROOT}/${app_name} <<__APPLESCRIPT__
on main(input)
    try
        tell application "Terminal"
            -- do script "echo" & space & input & space & "2>&1"
            -- do script "pwd" -- ==> /Users/foo
            -- do script "echo \`dirname" & space & input & "\`"
            do script ". /Applications/${app_name}/setup.sh; cd \`dirname" & space & input & "NO_KETCINDY__NO_LIFE\`"
        end tell
    end try
end main

on open argv
    main(quoted form of POSIX path of (item 1 of argv))
end open

on run
    main(quoted form of POSIX path of (choose folder))
end run
__APPLESCRIPT__

## アイコン置き換え
if [ -f ${BUILDROOT}/../artwork/ketcindy.icns ]; then
    cp -fva ${BUILDROOT}/../artwork/ketcindy.icns \
       ${BUILDROOT}/${app_name}/Contents/Resources/droplet.icns
fi

echo Finished
exit

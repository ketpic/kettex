!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "WinVer.nsh"
!include "x64.nsh"

Name "${KETTEXPKG}"
OutFile "${KETTEXPKG}.exe"
InstallDir "C:\kettex"

!searchparse "${KETTEXPKG}" "KeTTeX-windows-" KETTEX_VERSION
!define REG_UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\KeTTeX"
!define UNINSTALLER "$INSTDIR\uninstall.exe"

RequestExecutionLevel admin

SetCompressor /SOLID lzma
XPStyle on

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function .onInit
    # check for version later than vista
    # windows 9x, 2000, xp, vista unsupported
    ${If} ${AtMostWinXP}
        MessageBox MB_ICONSTOP "TeX Live does not run on this Windows version.$\r$\nTeX Live is supported on Windows 7 and later."
        Abort
    ${EndIf}
    ${If} ${IsWinVista}
        MessageBox MB_ICONEXCLAMATION "WARNING: Windows 7 is the earliest supported version.$\r$\nTeX Live 2020 has not been tested on Windows Vista."
    ${EndIf}

    ${IfNot} ${RunningX64}
        MessageBox MB_ICONSTOP "32-bit no longer supported"
        Abort
    ${EndIf}

    SetRegView 64
FunctionEnd

Section
    # check $INSTDIR
    DetailPrint "checking KeTTeX root directory $INSTDIR ..."
    ${If} ${FileExists} "$INSTDIR\*.*"
        ReadRegStr $0 HKLM "${REG_UNINSTALL_KEY}" "UninstallString"
        ${If} $0 == ""
            MessageBox MB_ICONSTOP "$INSTDIR already exists!$\r$\nInstaller does not install ${KETTEXPKG} in $INSTDIR"
            Abort
        ${Else}
            DetailPrint "old install detected. uninstalling ..."
            ExecWait "$0 /S _?=$INSTDIR"
            RMDir /r "$INSTDIR"
            ${If} ${FileExists} "$INSTDIR\*.*"
                MessageBox MB_ICONSTOP "Uninstallation failed. Please remove $INSTDIR manually and try again."
                Abort
            ${EndIf}
        ${EndIf}
    ${EndIf}
    DetailPrint "done  checking KeTTeX root directory $INSTDIR"

    # start installation
    DetailPrint "installing KeTTeX in $INSTDIR ... (It will take a while.)"
    SetOutPath "$INSTDIR"
    File /r "${KETTEXTEMP}/kettex/*"
    DetailPrint "done  installing KeTTeX in $INSTDIR"

    # post process
    DetailPrint "running post process ..."
    System::Call 'Kernel32::SetEnvironmentVariable(t "PATH", t "$INSTDIR\texlive\bin\windows;$SYSDIR;$WINDIR") i'
    # tlmgr platform set windows
    DetailPrint "(1/3) running updmap-sys ..."
    nsExec::Exec "updmap-sys"
    Pop $0
    ${If} $0 != 0
        MessageBox MB_ICONSTOP "updmap-sys failed."
        Abort
    ${EndIf}
    DetailPrint "done  running updmap-sys"
    DetailPrint "(2/3) running fmtutil-sys ... (It will take a while.)"
    nsExec::Exec "fmtutil-sys --all"
    Pop $0
    ${If} $0 != 0
        MessageBox MB_ICONSTOP "fmtutil-sys --all failed."
        Abort
    ${EndIf}
    DetailPrint "done  running fmtutil-sys"
    DetailPrint "(3/3) running luaotfload-tool --update ... (It will take a while.)"
    nsExec::Exec "luaotfload-tool --update --force"
    Pop $0
    ${If} $0 != 0
        MessageBox MB_ICONSTOP "luaotfload-tool --update --force failed."
        Abort
    ${EndIf}
    DetailPrint "done  running luaotfload-tool --update"
    DetailPrint "done  running post process"

    # register uninstaller
    WriteUninstaller "${UNINSTALLER}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "DisplayName" "KeTTeX"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "DisplayVersion" "${KETTEX_VERSION}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "UninstallString" '"${UNINSTALLER}"'
    WriteRegDWORD HKLM "${REG_UNINSTALL_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${REG_UNINSTALL_KEY}" "NoRepair" 1

    DetailPrint "Welcome to KeTTeX!"
SectionEnd

Function un.onInit
    SetRegView 64
FunctionEnd

Section "Uninstall"
    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "${REG_UNINSTALL_KEY}"
SectionEnd

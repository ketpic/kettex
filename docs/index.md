## KeTTeXのインストール

KeTTeXのリリース一覧[Releases - ketpic/kettex](https://github.com/ketpic/kettex/releases)から、各OSの最新版KeTTeXをダウンロードします。

 * Windows `windows`: `KeTTeX-windows-YYYYMMDD.zip`
 * macOS `universal-darwin` (`arm64`, `x86_64`): `KeTTeX-macos-YYYYMMDD.dmg`
 * Linux `x86_64-linux`, `aarch64-linux`: `KeTTeX-linux-YYYYMMDD.tar.zst`
 * FreeBSD `amd64-freebsd`: `KeTTeX-freebsd-YYYYMMDD.tar.zst`

### Windows
`KeTTeX-windows-YYYYMMDD.zip`を解凍して、同梱されているKeTTeX for Windowsの簡易インストーラー`kettexinst.cmd`を管理者権限で実行すると、標準で `C:\kettex`にKeTTeX for Windowsがインストールされます。

なお、`C:\kettex\kettex.cmd` を実行すると、`C:\kettex`のTeX Live環境のみが使えるようになったコマンドプロンプトが立ち上がります。

<!-- TODO: スクリーンショットとともに、インストール方法を説明する -->

<!-- TODO: PowerShell用も用意したほうがいい？ -->

### macOS
`KeTTeX-macos-YYYYMMDD.dmg`を開いて、同梱されているKeTTeX for macOSのアプリケーション`KeTTeX.app`をアプリケーションフォルダ`/Applications`にインストールします。

現時点で`KeTTeX.app`はApple公証を通していませんので、現状、以下のコマンドを実行することで、お手元で `/Applications/KeTTeX.app/` 以下のファイルを通常のどおり扱えるようになります。

```
sudo xattr -r -d com.apple.quarantine    /Applications/KeTTeX.app/
```

なお、`/Applications/KeTTeX.app`を実行すると、KeTTeX.appのTeX Live環境のみが使えるようになったターミナルが立ち上がります。

<!-- TODO: スクリーンショットとともに、インストール方法を説明する -->

### Linux (`x86_64-linux`, `aarch64-linux`), FreeBSD (`amd64-freebsd`)
1. `KeTTeX-linuxfreebsd-YYYYMMDD.tar.zst` を然るべきところに展開します。
2. ここでは、`/opt/kettex/` に展開された前提で、環境変数`PATH`に`/opt/kettex/bin/x86_64-linux/`を通したとします。
3. `fmtutil-sys --all` を実行します。

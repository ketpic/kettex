## KeTTeXのインストール

KeTTeXのリリース一覧[Releases - ketpic/kettex](https://github.com/ketpic/kettex/releases)から、各OSの最新版KeTTeXをダウンロードします。

 * Windows：`KeTTeX-windows-YYYYMMDD.zip`
 * macOS：`KeTTeX-macos-YYYYMMDD.dmg`
 * Linux：`KeTTeX-linux-YYYYMMDD.tar.zst`

### Windows
`KeTTeX-windows-YYYYMMDD.zip`を解凍して、同梱されているKeTTeX for Windowsの簡易インストーラー`kettexinst.cmd`を管理者権限で実行すると、`C:\kettex`にKeTTeX for Windowsがインストールされます。

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

### Linux
`KeTTeX-linux-YYYYMMDD.tar.zst` を然るべきところに展開します。

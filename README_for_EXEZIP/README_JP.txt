# PetitPomo

## 概要
PetitPomo（プティポモ）は、シンプルで小さなポモドーロタイマーです。
作業(Work)と休憩(Rest)を自動で切り替え、集中力の維持をサポートします。

## 特徴
- Work/Restを自動でループ。一時停止も可能。
- アプリは常に最前に配置。
- Work/Restの終わりに通知のポップアップ可能(ON/OFF切替可能)。
- ポモドーロのログをcsvで出力可能(ON/OFF切替可能)。

## 使い方
1. PetitPomo.exeをダブルクリックで実行。
2. Work/Restに分(min)を入力してください。
3. [Start]をクリックするとカウントダウンが始まります。
4. [Stop]をクリックするとカウントダウンが一時停止します。
5. [Reset]をクリックすると初期状態に戻ります。

## 設定
- […]をクリックすると設定画面が開きます。
- 設定内容は'PettiPomo_config.json'に保存されます。
- 「Notify on Rest/Work」にチェックを入れると、各時間終了時にポップアップ通知が5秒間表示されます。
- 「Enable CSV logging」にチェックを入れると、Rest 終了時に `PetitPomo_log.csv` へログが出力されます。

## 動作確認済の環境
OS：Windows 10 / 11

## ライセンス
本ソフトウェアはMITライセンスのもとで公開されています。
詳細は同梱の `LICENSE.txt` をご参照ください。

## Githubリンク
https://github.com/ataruno/PetitPomo
GitHubでは本アプリの Python ソースコードを公開されています。
また、同等の機能を PowerShell スクリプトで実現したバージョンも併せて掲載しています。

## 作者情報
- 開発者：ataruno
- X（旧Twitter）：[@ataruno_key](https://twitter.com/ataruno_key)

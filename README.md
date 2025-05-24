# PetitPomo
## Overview
PetitPomo is a simple and lightweight Pomodoro timer.  
It automatically switches between Work and Rest periods to help you stay focused.  

※[日本語のREADME](https://github.com/ataruno/PetitPomo?tab=readme-ov-file#japanese)は後半に記載  
PetitPomo（プティポモ）は、シンプルで小さなポモドーロタイマーです。  
作業(Work)と休憩(Rest)を自動で切り替え、集中力の維持をサポートします。  

# English
## Features
- Automatically loops between Work and Rest sessions, with optional pause.  
- Always stays on top of other windows.  
- Optional pop-up notifications at the end of Work/Rest sessions.  
- Option to export Pomodoro logs as a CSV file.  
- You can navigate between input fields and buttons using the Tab key.  

## How to Use
1. Double-click `PetitPomo.exe` to launch the application.  
2. Enter the duration (in minutes) for Work and Rest sessions.  
3. Click [Start] to begin the countdown.  
4. Click [Stop] to pause the timer.  
5. Click [Reset] to return to the initial state.  

## Settings
- Click […] to open the settings window.  
- Settings are saved in PetitPomo_config.json (the file is automatically created if it does not exist).  
- Enable "Notify on Rest/Work" to show a 5-second popup notification when each session ends.  
- Enable "Enable CSV logging" to automatically export logs to `PetitPomo_log.csv` at the end of each Rest session.  

## Tested Environment
OS: Windows 10 / 11  

## License
This software is released under the MIT License.  
See the included `LICENSE.txt` file for details.  

## GitHub
https://github.com/ataruno/PetitPomo  
The Python source code of this app is available on GitHub.  
A PowerShell version with similar features is also included.  

## Author
- Developer: ataruno  
- X (formerly Twitter): [@ataruno_key](https://twitter.com/ataruno_key)  

# Japanese
## 特徴
- Work/Restを自動でループ。一時停止も可能。  
- アプリは常に最前に配置。  
- Work/Restの終わりに通知のポップアップ可能(ON/OFF切替可能)。  
- ポモドーロのログをcsvで出力可能(ON/OFF切替可能)。  
- Tabキーで入力フォームやボタン間のフォーカス移動可能。  

## 使い方
1. PetitPomo.exeをダブルクリックで実行。  
2. Work/Restに分(min)を入力してください。  
3. [Start]をクリックするとカウントダウンが始まります。  
4. [Stop]をクリックするとカウントダウンが一時停止します。  
5. [Reset]をクリックすると初期状態に戻ります。  

## 設定
- […]をクリックすると設定画面が開きます。  
- 設定内容は 'PetitPomo_config.json' に保存されます（ファイルがない場合は自動で生成されます）。  
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

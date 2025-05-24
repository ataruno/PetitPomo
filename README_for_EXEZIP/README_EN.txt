# PetitPomo

## Overview
PetitPomo is a simple and lightweight Pomodoro timer.
It automatically switches between Work and Rest periods to help you stay focused.

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
The Python source code for this app is available on GitHub.
A PowerShell script version with similar features is also available.

## Author
- Developer: ataruno
- X (formerly Twitter): [@ataruno_key](https://twitter.com/ataruno_key)

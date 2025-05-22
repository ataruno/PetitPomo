Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load settings from config.json
$configPath = Join-Path -Path (Get-Location) -ChildPath "config.json"
if (Test-Path $configPath) {
    $json = Get-Content $configPath -Raw | ConvertFrom-Json
    $Script:notifyOnRest = $json.NotifyOnRest
    $Script:enableCsvLogging = $json.EnableCsvLogging
} else {
    $Script:notifyOnRest = $false
    $Script:enableCsvLogging = $false
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PettiPomo"
$form.Size = New-Object System.Drawing.Size(200,180)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $true

# Menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)

$menuSettings = New-Object System.Windows.Forms.ToolStripMenuItem "Settings"
$menuStrip.Items.Add($menuSettings)

# NotifyIcon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.Visible = $false

# UI Controls
$labelWork = New-Object System.Windows.Forms.Label
$labelWork.Text = "Work(min):"
$labelWork.Location = New-Object System.Drawing.Point(10,30)
$labelWork.AutoSize = $true
$form.Controls.Add($labelWork)

$textWork = New-Object System.Windows.Forms.TextBox
$textWork.Location = New-Object System.Drawing.Point(90,30)
$textWork.Size = New-Object System.Drawing.Size(50,20)
$textWork.Text = "25"
$form.Controls.Add($textWork)

$labelRest = New-Object System.Windows.Forms.Label
$labelRest.Text = "Rest(min):"
$labelRest.Location = New-Object System.Drawing.Point(10,50)
$labelRest.AutoSize = $true
$form.Controls.Add($labelRest)

$textRest = New-Object System.Windows.Forms.TextBox
$textRest.Location = New-Object System.Drawing.Point(90,50)
$textRest.Size = New-Object System.Drawing.Size(50,20)
$textRest.Text = "5"
$form.Controls.Add($textRest)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.Location = New-Object System.Drawing.Point(10,75)
$buttonStart.Size = New-Object System.Drawing.Size(50,30)
$form.Controls.Add($buttonStart)

$buttonStop = New-Object System.Windows.Forms.Button
$buttonStop.Text = "Stop"
$buttonStop.Location = New-Object System.Drawing.Point(65,75)
$buttonStop.Size = New-Object System.Drawing.Size(50,30)
$form.Controls.Add($buttonStop)

$buttonReset = New-Object System.Windows.Forms.Button
$buttonReset.Text = "Reset"
$buttonReset.Location = New-Object System.Drawing.Point(120,75)
$buttonReset.Size = New-Object System.Drawing.Size(50,30)
$form.Controls.Add($buttonReset)

$labelCountdown = New-Object System.Windows.Forms.Label
$labelCountdown.Text = "00:00"
$labelCountdown.Font = New-Object System.Drawing.Font("Arial",20,[System.Drawing.FontStyle]::Bold)
$labelCountdown.AutoSize = $true
$labelCountdown.Location = New-Object System.Drawing.Point(50,110)
$form.Controls.Add($labelCountdown)

# Timer and state variables
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$Script:phase = ""
$Script:timeLeft = 0
$Script:running = $false

$Script:logData = @{
    Date = ""
    WorkStart = ""
    WorkEnd = ""
    RestStart = ""
    RestEnd = ""
}

function UpdateCountdownLabel {
    $minutes = [int][math]::Floor($Script:timeLeft / 60)
    $seconds = [int]$Script:timeLeft % 60
    $labelCountdown.Text = "{0:D2}:{1:D2}" -f $minutes, $seconds
    $labelCountdown.Refresh()
}

function UpdateLabelFonts {
    $normalFont = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Regular)
    $boldFont = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)

    $labelWork.Font = $normalFont
    $labelRest.Font = $normalFont

    if ($Script:running) {
        switch ($Script:phase) {
            "work" { $labelWork.Font = $boldFont }
            "rest" { $labelRest.Font = $boldFont }
        }
    }
}

function ValidatePositiveNumber($text) {
    try {
        $num = [double]::Parse($text)
        if ($num -le 0) { throw }
        return $num
    } catch {
        return $null
    }
}

function SetPhaseTime {
    switch ($Script:phase) {
        "work" {
            $workMin = ValidatePositiveNumber $textWork.Text
            if (-not $workMin) {
                [System.Windows.Forms.MessageBox]::Show("Work time must be a positive number.")
                return $false
            }
            $Script:timeLeft = [int]($workMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,255,182,193)
            $Script:logData.WorkStart = (Get-Date).ToString("HH:mm:ss")
            $Script:logData.Date = (Get-Date).ToString("yyyy-MM-dd")
        }
        "rest" {
            $restMin = ValidatePositiveNumber $textRest.Text
            if (-not $restMin) {
                [System.Windows.Forms.MessageBox]::Show("Rest time must be a positive number.")
                return $false
            }
            $Script:timeLeft = [int]($restMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,144,238,144)
            $Script:logData.WorkEnd = (Get-Date).ToString("HH:mm:ss")
            $Script:logData.RestStart = (Get-Date).ToString("HH:mm:ss")
        }
        default {
            return $false
        }
    }
    return $true
}

function LogSessionToCsv {
    $Script:logData.RestEnd = (Get-Date).ToString("HH:mm:ss")
    $line = "{0},{1},{2},{3},{4}," -f $Script:logData.Date, $Script:logData.WorkStart, $Script:logData.WorkEnd, $Script:logData.RestStart, $Script:logData.RestEnd
    $logFile = Join-Path -Path (Get-Location) -ChildPath "pomodoro_log.csv"
    if (-not (Test-Path $logFile)) {
        "Date,WorkStart,WorkEnd,RestStart,RestEnd,Memo" | Out-File -FilePath $logFile -Encoding UTF8
    }
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function ShowRestNotification {
    if (-not $Script:notifyOnRest) { return }
    $notifyIcon.BalloonTipTitle = "Rest Time"
    $notifyIcon.BalloonTipText = "Rest time! Please relax."
    $notifyIcon.Visible = $true
    $notifyIcon.ShowBalloonTip(3000)
}

function ShowWorkNotification {
    if (-not $Script:notifyOnRest) { return }
    $notifyIcon.BalloonTipTitle = "Work Time"
    $notifyIcon.BalloonTipText = "Work time! Let's focus."
    $notifyIcon.Visible = $true
    $notifyIcon.ShowBalloonTip(3000)
}

function StartTimer {
    if ($timer.Enabled) { return }
    if ([string]::IsNullOrEmpty($Script:phase)) {
        $Script:phase = "work"
    }
    if ($Script:timeLeft -le 0) {
        if (-not (SetPhaseTime)) { return }
        UpdateCountdownLabel
    }
    $timer.Start()
    $Script:running = $true
    UpdateLabelFonts
}

$timer.Add_Tick({
    if (-not $Script:running) { return }
    if ($Script:timeLeft -gt 0) {
        $Script:timeLeft--
        UpdateCountdownLabel
    } else {
        if ($Script:phase -eq "rest") {
            if ($Script:enableCsvLogging) {
                LogSessionToCsv
            }
        }

        $Script:phase = if ($Script:phase -eq "work") { "rest" } else { "work" }

        if ($Script:phase -eq "rest") {
            ShowRestNotification
        } else {
            ShowWorkNotification
        }

        if (SetPhaseTime) {
            UpdateLabelFonts
            UpdateCountdownLabel
        }
    }
})

$buttonStart.Add_Click({ if (-not $Script:running) { StartTimer } })
$buttonStop.Add_Click({ $timer.Stop(); $Script:running = $false; UpdateLabelFonts })
$buttonReset.Add_Click({
    $timer.Stop()
    $Script:running = $false
    $Script:phase = ""
    $form.BackColor = [System.Drawing.Color]::White
    $Script:timeLeft = 0
    $labelCountdown.Text = "00:00"
    UpdateLabelFonts
})

$form.Add_Shown({
    $Script:phase = ""
    $form.BackColor = [System.Drawing.Color]::White
    $labelCountdown.Text = "00:00"
    UpdateLabelFonts
})

function ShowSettingsForm {
    $settingsForm = New-Object System.Windows.Forms.Form
    $settingsForm.Text = "Settings"
    $settingsForm.Size = New-Object System.Drawing.Size(280,180)
    $settingsForm.StartPosition = "CenterParent"
    $settingsForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $settingsForm.MaximizeBox = $false
    $settingsForm.MinimizeBox = $false
    $settingsForm.ControlBox = $true

    $chkNotify = New-Object System.Windows.Forms.CheckBox
    $chkNotify.Text = "Show rest time notification"
    $chkNotify.Location = New-Object System.Drawing.Point(20,30)
    $chkNotify.AutoSize = $true
    $chkNotify.Checked = $Script:notifyOnRest
    $settingsForm.Controls.Add($chkNotify)

    $chkLog = New-Object System.Windows.Forms.CheckBox
    $chkLog.Text = "Log session to CSV"
    $chkLog.Location = New-Object System.Drawing.Point(20,60)
    $chkLog.AutoSize = $true
    $chkLog.Checked = $Script:enableCsvLogging
    $settingsForm.Controls.Add($chkLog)

    $btnSave = New-Object System.Windows.Forms.Button
    $btnSave.Text = "Save"
    $btnSave.Location = New-Object System.Drawing.Point(100,100)
    $btnSave.Size = New-Object System.Drawing.Size(75,23)
    $btnSave.Add_Click({
        $Script:notifyOnRest = $chkNotify.Checked
        $Script:enableCsvLogging = $chkLog.Checked
        $settings = @{
            NotifyOnRest = $Script:notifyOnRest
            EnableCsvLogging = $Script:enableCsvLogging
        }
        $settings | ConvertTo-Json -Depth 3 | Set-Content -Encoding UTF8 $configPath
        $settingsForm.Close()
    })
    $settingsForm.Controls.Add($btnSave)

    $settingsForm.ShowDialog()
}

$menuSettings.Add_Click({ ShowSettingsForm })

[void]$form.ShowDialog()

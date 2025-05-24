Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$base64Icon = @"
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
"@

[byte[]]$iconBytes = [Convert]::FromBase64String($base64Icon)
$stream = New-Object System.IO.MemoryStream(,$iconBytes)
$icon = New-Object System.Drawing.Icon($stream)

# Load settings from config.json
$configPath = Join-Path -Path (Get-Location) -ChildPath "PettiPomo_config.json"
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
$form.WindowState = 'Normal'
$form.AutoScaleMode = "None"
$form.MinimumSize = New-Object System.Drawing.Size(25, 25)
$form.ClientSize = New-Object System.Drawing.Size(20, 145)
$form.Size = New-Object System.Drawing.Size(70,145)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.BackColor = [System.Drawing.Color]::LightGray
$form.TopMost = $true
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $true
$form.Icon = $icon

# Menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.Dock = [System.Windows.Forms.DockStyle]::None
$menuStrip.Location = New-Object System.Drawing.Point(110, 45)
$menuStrip.Size = New-Object System.Drawing.Size(50, 24)
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)
$symbolFont = New-Object System.Drawing.Font("Segoe UI", 10,[System.Drawing.FontStyle]::Bold)
$menuSettings = New-Object System.Windows.Forms.ToolStripMenuItem "..."
$menuSettings.Font = $symbolFont
$menuStrip.Items.Add($menuSettings)

# NotifyIcon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.Visible = $false

# UI Controls
$labelWork = New-Object System.Windows.Forms.Label
$labelWork.Text = "Work (min)"
$labelWork.Location = New-Object System.Drawing.Point(10,2)
$labelWork.Size = New-Object System.Drawing.Size(75,20)
# $labelWork.AutoSize = $true
$form.Controls.Add($labelWork)

$textWork = New-Object System.Windows.Forms.TextBox
$textWork.BorderStyle
$textWork.Location = New-Object System.Drawing.Point(90,2)
$textWork.Size = New-Object System.Drawing.Size(40,20)
$textWork.Text = "25"
$form.Controls.Add($textWork)

$labelRest = New-Object System.Windows.Forms.Label
$labelRest.Text = "Rest (min)"
$labelRest.Location = New-Object System.Drawing.Point(10,22)
$labelRest.Size = New-Object System.Drawing.Size(75,20)
# $labelRest.AutoSize = $true
$form.Controls.Add($labelRest)

$textRest = New-Object System.Windows.Forms.TextBox
$textRest.Location = New-Object System.Drawing.Point(90,22)
$textRest.Size = New-Object System.Drawing.Size(40,20)
$textRest.Text = "5"
$form.Controls.Add($textRest)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.FlatStyle = 'Popup'
$buttonStart.Location = New-Object System.Drawing.Point(8,46)
$buttonStart.Size = New-Object System.Drawing.Size(50,25)
$form.Controls.Add($buttonStart)

$buttonReset = New-Object System.Windows.Forms.Button
$buttonReset.Text = "Reset"
$buttonReset.FlatStyle = 'Popup'
$buttonReset.Location = New-Object System.Drawing.Point(65,46)
$buttonReset.Size = New-Object System.Drawing.Size(45,25)
$form.Controls.Add($buttonReset)

$labelCountdown = New-Object System.Windows.Forms.Label
$labelCountdown.Text = "00:00"
$labelCountdown.Font = New-Object System.Drawing.Font("Segoe UI",22,[System.Drawing.FontStyle]::Bold)
$labelCountdown.Location = New-Object System.Drawing.Point(20,62)
$labelCountdown.Size = New-Object System.Drawing.Size(120,50)
$labelCountdown.TextAlign = 'MiddleCenter'
$labelCountdown.AutoSize = $false
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
    $normalFont = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Regular)
    $boldFont = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
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
    $workMin = ValidatePositiveNumber $textWork.Text
    $restMin = ValidatePositiveNumber $textRest.Text
    switch ($Script:phase) {
        "work" {
            $Script:timeLeft = [int]($workMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,255,182,193)
            $menuStrip.BackColor = [System.Drawing.Color]::FromArgb(255,255,182,193)
            $Script:logData.WorkStart = (Get-Date).ToString("HH:mm:ss")
            $Script:logData.Date = (Get-Date).ToString("yyyy-MM-dd")
        }
        "rest" {
            $Script:timeLeft = [int]($restMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,144,238,144)
            $menuStrip.BackColor = [System.Drawing.Color]::FromArgb(255,144,238,144)
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
    $logFile = Join-Path -Path (Get-Location) -ChildPath "PettiPomo_log.csv"
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

$buttonReset.Add_Click({
    $timer.Stop()
    $Script:running = $false
    $Script:phase = ""
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke
    $menuStrip.BackColor = [System.Drawing.Color]::WhiteSmoke
    $Script:timeLeft = 0
    $labelCountdown.Text = "00:00"
    $buttonStart.Text = "Start"
    UpdateLabelFonts
})

$buttonStart.Add_Click({
    $workMin = ValidatePositiveNumber $textWork.Text
    $restMin = ValidatePositiveNumber $textRest.Text
    if (-not $workMin) {
        [System.Windows.Forms.MessageBox]::Show("Work time must be a positive number.")
        return $false
    }
    elseif ($workMin -gt 999) {
        [System.Windows.Forms.MessageBox]::Show("Work time must be a positive number less than 1000[min].")
        return $false
    }
    elseif (-not $restMin) {
        [System.Windows.Forms.MessageBox]::Show("Rest time must be a positive number.")
        return $false
    }
    elseif ($restMin -gt 999) {
        [System.Windows.Forms.MessageBox]::Show("Rest time must be a positive number less than 1000[min].")
        return $false
    }
    elseif (-not $Script:running) {
        if ([string]::IsNullOrEmpty($Script:phase)) {
            $Script:phase = "work"
        }
        if ($Script:timeLeft -le 0) {
            if (-not (SetPhaseTime)) { return }
            UpdateCountdownLabel
        }
        $timer.Start()
        $Script:running = $true
        $buttonStart.Text = "Stop"
    } else {
        $timer.Stop()
        $Script:running = $false
        $buttonStart.Text = "Start"
    }
    UpdateLabelFonts
})

$form.Add_Shown({
    $Script:phase = ""
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke
    $menuStrip.BackColor = [System.Drawing.Color]::WhiteSmoke
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
    $settingsForm.TopMost = $true

    $chkNotify = New-Object System.Windows.Forms.CheckBox
    $chkNotify.Text = "Show rest time notification"
    $chkNotify.Location = New-Object System.Drawing.Point(20,20)
    $chkNotify.AutoSize = $true
    $chkNotify.Checked = $Script:notifyOnRest
    $settingsForm.Controls.Add($chkNotify)

    $chkLog = New-Object System.Windows.Forms.CheckBox
    $chkLog.Text = "Log session to CSV"
    $chkLog.Location = New-Object System.Drawing.Point(20,50)
    $chkLog.AutoSize = $true
    $chkLog.Checked = $Script:enableCsvLogging
    $settingsForm.Controls.Add($chkLog)

    $btnSave = New-Object System.Windows.Forms.Button
    $btnSave.Text = "Save"
    $btnSave.Location = New-Object System.Drawing.Point(100,80)
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

    $LabelMaker = New-Object System.Windows.Forms.Label
    $LabelMaker.Text = "designed by ataruno"
    $LabelMaker.Location = New-Object System.Drawing.Point(145,120)
    $LabelMaker.Size = New-Object System.Drawing.Size(200,50)
    $settingsForm.Controls.Add($LabelMaker)

    $settingsForm.ShowDialog()
}

$menuSettings.Add_Click({ ShowSettingsForm })

$form.ShowDialog() | Out-Null
exit 0
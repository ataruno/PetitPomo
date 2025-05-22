Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pomodoro Timer"
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

# NotifyIcon for tray notifications
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
$Script:notifyOnRest = $false

# Functions

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
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,255,182,193) # LightPink
        }
        "rest" {
            $restMin = ValidatePositiveNumber $textRest.Text
            if (-not $restMin) {
                [System.Windows.Forms.MessageBox]::Show("Rest time must be a positive number.")
                return $false
            }
            $Script:timeLeft = [int]($restMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,144,238,144) # LightGreen
        }
        default {
            return $false
        }
    }
    return $true
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
        # Switch phase
        $Script:phase = if ($Script:phase -eq "work") { "rest" } else { "work" }

        # Show notification depending on phase
        if ($Script:phase -eq "rest") {
            ShowRestNotification
        } elseif ($Script:phase -eq "work") {
            ShowWorkNotification
        }

        if (SetPhaseTime) {
            UpdateLabelFonts
            UpdateCountdownLabel
        }
    }
})

$buttonStart.Add_Click({
    if (-not $Script:running) {
        StartTimer
    }
})

$buttonStop.Add_Click({
    $timer.Stop()
    $Script:running = $false
    UpdateLabelFonts
})

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
    $settingsForm.Size = New-Object System.Drawing.Size(270,150)
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

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "OK"
    $btnOK.Location = New-Object System.Drawing.Point(50,80)
    $btnOK.Size = New-Object System.Drawing.Size(60,30)
    $settingsForm.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(150,80)
    $btnCancel.Size = New-Object System.Drawing.Size(60,30)
    $settingsForm.Controls.Add($btnCancel)

    $btnOK.Add_Click({
        $Script:notifyOnRest = $chkNotify.Checked
        $settingsForm.Close()
    })

    $btnCancel.Add_Click({
        $settingsForm.Close()
    })

    $settingsForm.ShowDialog()
}

$menuSettings.Add_Click({
    ShowSettingsForm
})

[void]$form.ShowDialog()

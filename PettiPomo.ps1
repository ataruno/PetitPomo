Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pomodoro Timer"
$form.Size = New-Object System.Drawing.Size(300,230)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $true

# Add menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)

# Add "Settings" menu
$menuSettings = New-Object System.Windows.Forms.ToolStripMenuItem "Settings"
$menuStrip.Items.Add($menuSettings)

# Global variable for notification toggle
$script:notifyOnRest = $true

# Work label and input
$labelWork = New-Object System.Windows.Forms.Label
$labelWork.Text = "Work (minutes):"
$labelWork.Location = New-Object System.Drawing.Point(10,50)
$labelWork.AutoSize = $true
$form.Controls.Add($labelWork)

$textWork = New-Object System.Windows.Forms.TextBox
$textWork.Location = New-Object System.Drawing.Point(110,48)
$textWork.Size = New-Object System.Drawing.Size(50,20)
$textWork.Text = "25"
$form.Controls.Add($textWork)

# Rest label and input
$labelRest = New-Object System.Windows.Forms.Label
$labelRest.Text = "Rest (minutes):"
$labelRest.Location = New-Object System.Drawing.Point(10,80)
$labelRest.AutoSize = $true
$form.Controls.Add($labelRest)

$textRest = New-Object System.Windows.Forms.TextBox
$textRest.Location = New-Object System.Drawing.Point(110,78)
$textRest.Size = New-Object System.Drawing.Size(50,20)
$textRest.Text = "5"
$form.Controls.Add($textRest)

# Buttons
$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.Location = New-Object System.Drawing.Point(20,110)
$buttonStart.Size = New-Object System.Drawing.Size(60,30)
$form.Controls.Add($buttonStart)

$buttonStop = New-Object System.Windows.Forms.Button
$buttonStop.Text = "Stop"
$buttonStop.Location = New-Object System.Drawing.Point(100,110)
$buttonStop.Size = New-Object System.Drawing.Size(60,30)
$form.Controls.Add($buttonStop)

$buttonReset = New-Object System.Windows.Forms.Button
$buttonReset.Text = "Reset"
$buttonReset.Location = New-Object System.Drawing.Point(180,110)
$buttonReset.Size = New-Object System.Drawing.Size(60,30)
$form.Controls.Add($buttonReset)

# Countdown display
$labelCountdown = New-Object System.Windows.Forms.Label
$labelCountdown.Text = "00:00"
$labelCountdown.Font = New-Object System.Drawing.Font("Arial",20,[System.Drawing.FontStyle]::Bold)
$labelCountdown.AutoSize = $true
$labelCountdown.Location = New-Object System.Drawing.Point(100,150)
$form.Controls.Add($labelCountdown)

# Timer setup
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$script:phase = ""      # "", "work", or "rest"
$script:timeLeft = 0
$script:running = $false

function UpdateCountdownLabel {
    $minutes = [int]([math]::Floor($script:timeLeft / 60))
    $seconds = [int]($script:timeLeft % 60)
    $labelCountdown.Text = "{0:D2}:{1:D2}" -f $minutes, $seconds
    $labelCountdown.Refresh()
}

function UpdateLabelFonts {
    $normalFont = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Regular)
    $boldFont = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)

    $labelWork.Font = $normalFont
    $labelRest.Font = $normalFont

    if ($script:running) {
        if ($script:phase -eq "work") {
            $labelWork.Font = $boldFont
        } elseif ($script:phase -eq "rest") {
            $labelRest.Font = $boldFont
        }
    }
}

function SetPhaseTime {
    if ($script:phase -eq "work") {
        try {
            $workMin = [double]::Parse($textWork.Text)
            if ($workMin -le 0) { throw }
            $script:timeLeft = [int]($workMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,255,182,193) # LightPink
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Work time must be a positive number")
            return $false
        }
    } elseif ($script:phase -eq "rest") {
        try {
            $restMin = [double]::Parse($textRest.Text)
            if ($restMin -le 0) { throw }
            $script:timeLeft = [int]($restMin * 60)
            $form.BackColor = [System.Drawing.Color]::FromArgb(255,144,238,144) # LightGreen
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Rest time must be a positive number")
            return $false
        }
    } else {
        return $false
    }
    return $true
}

function StartTimer {
    if ($timer.Enabled) {
        return
    }
    if ($script:phase -eq "") {
        $script:phase = "work"
    }
    if ($script:timeLeft -le 0) {
        if (-not (SetPhaseTime)) {
            return
        }
        UpdateCountdownLabel
    }
    $timer.Start()
    $script:running = $true
    UpdateLabelFonts
}

$timer.Add_Tick({
    if ($script:running) {
        if ($script:timeLeft -gt 0) {
            $script:timeLeft--
            UpdateCountdownLabel
        } else {
            # Change phase
            $script:phase = if ($script:phase -eq "work") { "rest" } else { "work" }

            # Show non-blocking notification on rest phase if enabled
            if ($script:phase -eq "rest" -and $script:notifyOnRest) {
                $notify = New-Object System.Windows.Forms.Form
                $notify.Text = "Rest Time"
                $notify.Size = New-Object System.Drawing.Size(250,120)
                $notify.StartPosition = "CenterScreen"
                $notify.TopMost = $true
                $notify.FormBorderStyle = "FixedDialog"

                $label = New-Object System.Windows.Forms.Label
                $label.Text = "Rest time! Please relax."
                $label.AutoSize = $true
                $label.Location = New-Object System.Drawing.Point(50,30)
                $notify.Controls.Add($label)

                $notify.Add_FormClosed({
                    Start-RestCountdown
                })

                $notify.ShowDialog()
            }


            if (SetPhaseTime) {
                UpdateLabelFonts
                UpdateCountdownLabel
            }
        }
    }
})

$buttonStart.Add_Click({
    if (-not $script:running) {
        StartTimer
    }
})

$buttonStop.Add_Click({
    $timer.Stop()
    $script:running = $false
    UpdateLabelFonts
})

$buttonReset.Add_Click({
    $timer.Stop()
    $script:running = $false
    $script:phase = ""
    $form.BackColor = [System.Drawing.Color]::White
    $script:timeLeft = 0
    $labelCountdown.Text = "00:00"
    UpdateLabelFonts
})

$form.Add_Shown({
    $script:phase = ""
    $form.BackColor = [System.Drawing.Color]::White
    $labelCountdown.Text = "00:00"
    UpdateLabelFonts
})

function ShowSettingsForm {
    $settingsForm = New-Object System.Windows.Forms.Form
    $settingsForm.Text = "Settings"
    $settingsForm.Size = New-Object System.Drawing.Size(250,150)
    $settingsForm.StartPosition = "CenterParent"
    $settingsForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $settingsForm.MaximizeBox = $false
    $settingsForm.MinimizeBox = $false
    $settingsForm.ControlBox = $true

    $chkNotify = New-Object System.Windows.Forms.CheckBox
    $chkNotify.Text = "Rest time popup notification"
    $chkNotify.Location = New-Object System.Drawing.Point(20,30)
    $chkNotify.AutoSize = $true
    $chkNotify.Checked = $script:notifyOnRest
    $settingsForm.Controls.Add($chkNotify)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "OK"
    $btnOK.Location = New-Object System.Drawing.Point(50,80)
    $btnOK.Size = New-Object System.Drawing.Size(60,30)
    $settingsForm.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(130,80)
    $btnCancel.Size = New-Object System.Drawing.Size(60,30)
    $settingsForm.Controls.Add($btnCancel)

    $btnOK.Add_Click({
        $script:notifyOnRest = $chkNotify.Checked
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

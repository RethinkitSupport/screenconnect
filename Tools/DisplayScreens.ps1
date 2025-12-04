Write-Host "----------------------------------------------------"
Write-Host "Screen and Display Reporting"
Write-Host "----------------------------------------------------"
#region Transcript Open
$Transcript = [System.IO.Path]::GetTempFileName()               
Start-Transcript -path $Transcript | Out-Null
#endregion Transcript Open
# Check if the session is running as administrator
$isAdmin = $true # ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script must be run as administrator. Exiting."
    Start-Sleep 2
} # not admin
else {
    Write-Host "----------------------------------------------------"
    Write-Host "Get-CimInstance -ClassName Win32_DesktopMonitor"
    Get-CimInstance -ClassName Win32_DesktopMonitor | Select-Object Name, ScreenWidth, ScreenHeight | Out-Host
    Write-Host "----------------------------------------------------"
    Write-Host "Get-CimInstance -Namespace root\wmi -Class WmiMonitorID"
    Get-CimInstance -Namespace root\wmi -Class WmiMonitorID |
    ForEach-Object {
        [PSCustomObject]@{
            Manufacturer = ([System.Text.Encoding]::ASCII.GetString($_.ManufacturerName)).Trim([char]0)
            Model        = ([System.Text.Encoding]::ASCII.GetString($_.ProductCodeID)).Trim([char]0)
            Serial       = ([System.Text.Encoding]::ASCII.GetString($_.SerialNumberID)).Trim([char]0)
        }
    } | Out-Host
    Write-Host "----------------------------------------------------"
} # is admin
#region Transcript Save
$FolderTranscript = "C:\Screenconnect Logs\Set Timezone and Prevent AutoTZUpdater"
Stop-Transcript | Out-Null
$date = get-date -format "yyyy-MM-dd_HH-mm-ss"
New-Item -Path $FolderTranscript -ItemType Directory -Force | Out-Null # Make Logs folder (deeply)
$TranscriptTarget = Join-Path $FolderTranscript ("PS1_"+$date+"_log.txt")
If (Test-Path $TranscriptTarget) {Remove-Item $TranscriptTarget -Force} # Remove old log file if it exists
Move-Item $Transcript $TranscriptTarget -Force
Write-Host "Transcript saved to: $TranscriptTarget"
#endregion Transcript Save
Write-Host "Done. Exiting in 3 seconds."
Start-Sleep 3
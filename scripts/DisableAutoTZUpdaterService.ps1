Write-Host "----------------------------------------------------"
Write-Host "Fixes a Problem with Windows 24H2 TimeZone adjustments for non-admins"
Write-Host ""
Write-Host "Issues:"
Write-Host "The modern settings app doesn't allow non-admins to change TZ"
Write-Host "The Auto Time Zone Updater service is enabled and can't be disabled by non-admins"
Write-Host ""
Write-Host "Fixes:"
Write-Host "Disable 'Auto Time Zone Updater' Service (If needed. Can be turned back on by admins by the toggle in Settings app)"
Write-Host "Sets Time Zone based on location (A one-time adjustment just in case the TZ is set wrong by the service)"
Write-Host "----------------------------------------------------"
#region Transcript Open
$Transcript = [System.IO.Path]::GetTempFileName()               
Start-Transcript -path $Transcript | Out-Null
#endregion Transcript Open
# Check if the session is running as administrator
Write-Host "Fixes a Problem with Windows 24H2 TimeZone adjustments for non-admins..."
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script must be run as administrator. Exiting."
    Start-Sleep 2
} # not admin
else {
    Write-Host "Admin confirmed. Proceeding in 10 seconds.  Press Ctrl-C to cancel."
    Start-Sleep 10
    Write-Host "----------------------------------------------------"
    Write-Host "Disabling 'Auto Time Zone Updater' Service (if needed)"
    Write-Host "Get-Service -Name tzautoupdate"
    Get-Service -Name tzautoupdate | Select-Object Name,DisplayName,Status,StartType | Out-Host
    $tzservice = Get-Service -Name tzautoupdate
    if ($null -eq $tzservice) {
        Write-Host "Service 'tzautoupdate' not found. It may not be installed on this system."
    } elseif ($tzservice.StartType -eq 'Disabled') {
        Write-Host "Service 'tzautoupdate' is already disabled."
    } else {
        Write-Host "Stopping and disabling 'tzautoupdate' service..."
        Stop-Service -Name tzautoupdate -Force
        Set-Service -Name tzautoupdate -StartupType Disabled -PassThru
        Start-Sleep 2
        Write-Host "Get-Service -Name tzautoupdate (after changes)"
        Get-Service -Name tzautoupdate | Select-Object Name,DisplayName,Status,StartType | Out-Host
    }
    Write-Host "----------------------------------------------------"
    # Set Time Zone based on location (if needed)
    Write-Host "Setting Time Zone based on location"
    # Mapping of IANA time zones to Windows time zones
    $ianaToWindowsTimeZoneMap = @{
        "America/New_York"      = "Eastern Standard Time"
        "America/Chicago"       = "Central Standard Time"
        "America/Denver"        = "Mountain Standard Time"
        "America/Phoenix"       = "US Mountain Standard Time"
        "America/Los_Angeles"   = "Pacific Standard Time"
        "America/Anchorage"     = "Alaskan Standard Time"
        "America/Adak"          = "Aleutian Standard Time"
        "Pacific/Honolulu"      = "Hawaiian Standard Time"
        "Europe/London"         = "GMT Standard Time"
        "Europe/Paris"          = "Romance Standard Time"
        "Asia/Tokyo"            = "Tokyo Standard Time"
        "Australia/Sydney"      = "AUS Eastern Standard Time"
        # Add more mappings as needed
    }
    # Function to get the time zone based on the public IP address
    function Get-TimeZoneFromIP {
        Write-Host "Invoke-RestMethod -Uri https://ipapi.co/timezone/"
        try {
            # Use an external API to get the time zone based on the public IP address
            $response = Invoke-RestMethod -Uri "https://ipapi.co/timezone/" -ErrorAction Stop
            return $response
        } catch {
            Write-Host "Failed to retrieve time zone from IP address: $_"
            return $null
        }
    }
    # Get the current time zone
    $currentTimeZone = (Get-TimeZone).Id
    # Get the time zone based on the public IP address
    $detectedTimeZone = Get-TimeZoneFromIP
    if ($detectedTimeZone -and $ianaToWindowsTimeZoneMap.ContainsKey($detectedTimeZone)) {
        $windowsTimeZone = $ianaToWindowsTimeZoneMap[$detectedTimeZone]
        if ($currentTimeZone -ne $windowsTimeZone) {
            try {
                # Set the new time zone
                Set-TimeZone -Id $windowsTimeZone -ErrorAction Stop
                Write-Host "Time zone updated to: $windowsTimeZone"
            } catch {
                Write-Host "Failed to update time zone: $_"
            }
        } else {
            Write-Host "Time zone is already correct: $windowsTimeZone"
        }
    } else {
        Write-Warning "Detected time zone '$detectedTimeZone' is not mapped to a valid Windows time zone."
    }
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

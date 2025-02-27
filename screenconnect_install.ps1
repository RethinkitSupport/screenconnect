###
# This script has been posted to Rethinkit's GitHub for easy deployment
#
# To install Press Windows+R and paste this
# powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/screenconnect_install.ps1 -UseBasicParsing).Content
###
Param ## provide a comma separated list of switches
	(
	[string] $mode = "auto" #auto or manual
	)
$mode_auto = ($mode -eq "auto")
Function IsAdmin() 
{
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin=$prp.IsInRole($adm)
    $IsAdmin
}
###
$scriptName     = "screen_connect_install.ps1"
$UrlHost  = "rethinkit"
$UrlBase  = "https://$($UrlHost).screenconnect.com/Bin/ScreenConnect.ClientSetup.exe"
$Company    = "Unknown"
$Site       = "ScreenConnect"
$Dept       = ""
$DeviceType = ""
###
# Azure Info
Write-Host "Getting PC info (dsregcmd /status)..."
$dsregcmd = dsregcmd /status | Where-Object { $_ -match ' : ' } | ForEach-Object { $_.Trim() } | ConvertFrom-String -PropertyNames 'Name','Value' -Delimiter ' : '
$TenantName    = ($dsregcmd | Where-Object -Property Name -eq "TenantName").Value
if ($TenantName) {$Company=$TenantName}
# Public IP
Write-Host "  Getting public ip (http://ipinfo.io)..."
$PublicIP_Info = Invoke-RestMethod http://ipinfo.io/json -UseBasicParsing
$PublicIP      = $PublicIP_Info.ip
if ($PublicIP) {$site+=" Public IP $($PublicIP)"}
# Local IP
$LocalIP = Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile | Sort-Object InterfaceIndex | Select-Object -First 1 -ExpandProperty InterfaceIndex) -AddressFamily IPV4 | Select-Object -ExpandProperty IPAddress
if ($LocalIP) {$site+=" Local IP $($LocalIP)"}
###
Write-Host "-----------------------------------------------------------------------------"
Write-Host ("$scriptName        Computer:$env:computername User:$env:username PSver:"+($PSVersionTable.PSVersion.Major))
Write-host "Mode: $($mode)"
Write-host ""
Write-Host "Downloads and automatically installs Screenconnect."
Write-host ""
Write-host "   UrlBase: $($UrlBase)"
Write-host "   Company: $($Company)"
Write-host "      Site: $($Site)"
Write-host "      Dept: $($Dept)"
Write-host "DeviceType: $($DeviceType)"
Write-host "        PC: " -NoNewline
Write-Host $env:COMPUTERNAME -ForegroundColor Green
Write-host ""
Write-Host "-----------------------------------------------------------------------------"
if ($mode_auto) {Write-Host "Auto-install (in 5 seconds)";Start-Sleep 5} else {Pause}
# If (-not (Isadmin))
# {
# 	Write-Host "Requires elevation.  Re-run as admin."
# 	start-sleep 3
# 	exit 99
# }
$exitcode=0
# Convert settings to URL format
Add-Type -AssemblyName System.Web
$Company    = [System.Web.HttpUtility]::UrlEncode($Company)    -replace '\+', '%20'
$Site       = [System.Web.HttpUtility]::UrlEncode($Site)       -replace '\+', '%20'
$Dept       = [System.Web.HttpUtility]::UrlEncode($Dept)       -replace '\+', '%20'
$DeviceType = [System.Web.HttpUtility]::UrlEncode($DeviceType) -replace '\+', '%20'
# Get a temp file to download to
$tmpFile = Join-Path $Env:Temp (Split-Path $UrlBase -leaf)
# Get the download path
$WebUrl  = "$($UrlBase)?e=Access&y=Guest&c=$($Company)&c=$($Site)&c=$($Department)&c=$($DeviceType)&c=&c=&c=&c="
Write-Host "Download URL: " -NoNewline
Write-Host $WebUrl -ForegroundColor Green
# Download (without progress / faster)
$Pp_old=$ProgressPreference;$ProgressPreference = 'SilentlyContinue' # Change from default (Continue). Prevents byte display in Invoke-WebRequest (speeds it up)
Invoke-WebRequest -Uri $WebUrl -OutFile $tmpFile
$ProgressPreference = $Pp_old
# Downloaded?
if (Test-path $tmpFile) {
	Write-Host "Running: " -NoNewline
	Write-Host $tmpFile -ForegroundColor Green
	# Launch it
	Start-Process -Filepath $tmpFile -Wait
	# Delete it
	Remove-Item -Path $tmpFile -Force
} # Downloaded
Else { # didn't download
	Write-Host "Error Downloading: " -NoNewline
	Write-Host $tmpFile -ForegroundColor red
	$exitcode=19
} # didn't download
Start-Sleep 1
Write-Host "Done." -ForegroundColor Yellow
Exit $exitcode
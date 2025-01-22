###
# This script has been posted to Rethinkit's GitHub for easy deployment
#
# To install Press Windows+R and paste this
# powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/pcinfo/screenconnect/screenconnect_install.ps1 -UseBasicParsing).Content
#
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
$scriptFullname = $PSCommandPath ; if (!($scriptFullname)) {$scriptFullname =$MyInvocation.InvocationName }
$scriptDir      = Split-Path -Path $scriptFullname -Parent
$scriptName     = Split-Path -Path $scriptFullname -Leaf
if ((Test-Path("$scriptDir\ITAutomator.psm1"))) {Import-Module "$scriptDir\ITAutomator.psm1" -Force} else {write-host "Err 99: Couldn't find ITAutomator.psm1";Start-Sleep -Seconds 10;Exit(99)}
$UrlHost  = "rethinkit"
$UrlBase  = "https://$($UrlHost).screenconnect.com/Bin/ScreenConnect.ClientSetup.exe"
$Company    = "Rethinkit"
$Site       = "App Install - ScreenConnect (Rethinkit)"
$Dept       = ""
$DeviceType = ""
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
Write-host ""
Write-Host "-----------------------------------------------------------------------------"
if ($mode_auto) {PauseTimed -quiet} else {PauseTimed}
If (-not (Isadmin))
{
	Write-Host "Requires elevation.  Re-run as admin."
	start-sleep 3
	exit 99
}
#########
$tmpFile = Split-Path $UrlBase -leaf
###
$Company    = [System.Web.HttpUtility]::UrlEncode($Company)    -replace '\+', '%20'
$Site       = [System.Web.HttpUtility]::UrlEncode($Site)       -replace '\+', '%20'
$Dept       = [System.Web.HttpUtility]::UrlEncode($Dept)       -replace '\+', '%20'
$DeviceType = [System.Web.HttpUtility]::UrlEncode($DeviceType) -replace '\+', '%20'
###
$WebUrl  = "$($UrlBase)?e=Access&y=Guest&c=$($Company)&c=$($Site)&c=$($Department)&c=$($DeviceType)&c=&c=&c=&c="
####
$exitcode=0
$tmpFile=Join-Path $Env:Temp $tmpFile

$Pp_old=$ProgressPreference;$ProgressPreference = 'SilentlyContinue' # Change from default (Continue). Prevents byte display in Invoke-WebRequest (speeds it up)
Invoke-WebRequest -Uri $WebUrl -OutFile $tmpFile
$ProgressPreference = $Pp_old

if (Test-path $tmpFile) {
	Write-Host "Downloaded: " -NoNewline
	Write-Host $tmpFile -ForegroundColor Green
	$proc = Start-Process $tmpFile -ArgumentList $arglist -PassThru -Wait -NoNewWindow
	Remove-Item -Path $tmpFile -Force

}
Else {
	Write-Host "Error Downloading: " -NoNewline
	Write-Host $tmpFile -ForegroundColor red
	$exitcode=19
}
Start-Sleep 1
Write-Host "Done." -ForegroundColor Yellow
Exit $exitcode
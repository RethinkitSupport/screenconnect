# ScreenConnect Installer
#
# To Install from Command line (as admin):  Windows + R 
# powershell -executionpolicy bypass $ProgressPreference='SilentlyContinue';Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/refs/heads/main/screenconnect_install.ps1 -UseBasicParsing).Content 
#
Write-Host "Installing ScreenConnect..." -ForegroundColor Green
$url = "https://rethinkit.screenconnect.com/Bin/ScreenConnect.ClientSetup.exe?e=Access&y=Guest&c=Unassigned&c=&c=&c=&c=&c=&c=&c="
$outpath = "$($env:TEMP)\ScreenConnectInstaller.exe"
$wc = New-Object System.Net.WebClient
Write-Host "Downloading ($($outpath))..."
$wc.DownloadFile($url, $outpath)
Write-Host "Installing..."
Start-Process -Filepath $outpath -Wait
Write-Host "Cleanup..."
Remove-Item -Path $outpath -Force
Write-Host "Done." -ForegroundColor Green
Start-Sleep -Seconds 5

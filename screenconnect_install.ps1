Write-Host "Installing ScreenConnect..." -ForegroundColor Green
$url = "https://rethinkit2410101053.screenconnect.com/Bin/ScreenConnect.ClientSetup.exe?e=Access&y=Guest&c=Unassigned&c=&c=&c=&c=&c=&c=&c="
$outpath = "$($env:TEMP)\sc.exe"
$wc = New-Object System.Net.WebClient
Write-Host "Downloading..."
$wc.DownloadFile($url, $outpath)
Write-Host "Installing..."
Start-Process -Filepath $outpath -Wait
Write-Host "Cleanup..."
Remove-Item -Path $outpath -Force
Write-Host "Done." -ForegroundColor Green
Start-Sleep -Seconds 5

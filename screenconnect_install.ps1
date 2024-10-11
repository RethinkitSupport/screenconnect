$url = "https://rethinkit2410101053.screenconnect.com/Bin/ScreenConnect.ClientSetup.exe?e=Access&y=Guest&c=Rethinkit%20Internal&c=&c=&c=&c=&c=&c=&c="
$outpath = "C:\sc.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $outpath)
Start-Process -Filepath $outpath -Wait
Remove-Item -Path $outpath -Force
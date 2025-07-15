
# ScreenConnect GitHub Tools
Open command prompt (as admin) and paste this  

## screenconnect
Installs the Rethinkit screenconnect agent for remote support
`powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/screenconnect_install.ps1 -UseBasicParsing).Content`

## DisableAutoTZUpdaterService  
Disable 'Auto Time Zone Updater' Service (If needed. Can be turned back on by admins by the toggle in Settings app)  
Sets Time Zone based on location (A one-time adjustment just in case the TZ is set wrong by the service)  
`powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/Tools/DisableAutoTZUpdaterService.ps1 -UseBasicParsing).Content 

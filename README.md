
# ScreenConnect GitHub Tools
Open the Command Prompt (as Administrator) and paste these commands.  
The problem with these Invoke-Expression Invoke-WebRequest commands is that they often trigger anti-virus alerts.

## screenconnect
Installs the Rethinkit screenconnect agent for remote support
`powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/screenconnect_install.ps1 -UseBasicParsing).Content`

## DisableAutoTZUpdaterService  
Disable 'Auto Time Zone Updater' Service (If needed. Can be turned back on by admins by the toggle in Settings app)  
Sets Time Zone based on location (A one-time adjustment just in case the TZ is set wrong by the service)  
`powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/Tools/DisableAutoTZUpdaterService.ps1 -UseBasicParsing).Content`



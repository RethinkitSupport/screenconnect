# screenconnect
Installs the Rethinkit screenconnect agent for remove support


Command line (as admin) installer (Press Windows+R and paste this)  
`powershell -executionpolicy bypass Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/main/screenconnect_install.ps1 -UseBasicParsing).Content`

Old
powershell -executionpolicy bypass $ProgressPreference='SilentlyContinue';Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/RethinkitSupport/screenconnect/refs/heads/main/screenconnect_install.ps1 -UseBasicParsing).Content 

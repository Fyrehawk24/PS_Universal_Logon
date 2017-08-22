#region Global Settings
$GlobalHash = [hashtable]::Synchronized(@{})
$GlobalHash.CompanyName = "Wolcott, Wood and Taylor, Inc." 
$GlobalHash.FileServer = "wwt-fp03.wwtps.com"
$GlobalHash.FileServerHome = "wwt-fp01.wwtps.com"
$GlobalHash.PrintServer = "uivmwwtps01.wwtps.com"
$GlobalHash.PrintGroupsOU = "LDAP://OU=Printers,OU=Groups,DC=wwtps,DC=com"
$GlobalHash.Icon = "\\wwt-fp03.wwtps.com\Teams\it\Logos\Icons\WWT_AD_Photo_xp.ico"
$GlobalHash.Logo = "http://www.wwtps.com/logos/WWT UoI PBG_Blue 350x120.png"
$GlobalHash.LogoHight = 120
$GlobalHash.LogoWidth = 350
$GlobalHash.ExemptWorkstation = 0
$GlobalHash.UserGroups = ""
$GlobalHash.UserID = $env:username
$GlobalHash.UserHomeShare =  ("\\" + $GlobalHash.FileServerHome + "\users$\" + $GlobalHash.UserID)
$GlobalHash.PrintSpooler = $False
$GlobalHash.ForcePrinter= "PDFCREATOR"
$GlobalHash.StrPaperVisionWebAssistant = "C:\Program Files (x86)\Digitech Systems\PaperVision\PVWA\DSI.PVWA.Host.exe"
$GlobalHash.ChangeDefault = $True
$GlobalHash.LogUNC="\\wwt-fp01.wwtps.com\logs$\sessions_csv"
# the Windows Dir is added at the end of the Setup the Shell Folders section
$GlobalHash.CompanyDefaultWallpaper = ($env:SystemRoot + "\system32\oobe\info\backgrounds\background1920x1200.jpg")
$GlobalHash.CompanyDefaultWallpaperStyle="2"
#$GlobalHash.ComputerOULong = CStr(objSysInfo.ComputerName)
$GlobalHash.StrContact = "Please contact Support Desk at: support@wwtps.com or 312-704-2854"
$GlobalHash.MappedPrinters = (Get-WMIObject Win32_Printer -ComputerName $env:COMPUTERNAME | where{$_.Name -like “*\\*”} | select sharename,name)

#(Get-Printer | Select Name,ComputerName,Type,Portname,ShareName) 

$GlobalHash.NewLine = "`r`n"

#endregion

#region Global Functions
function GetADObject
{
    param([string] $objectName, [string] $objectType)
    
    switch ($objectType)
        {
        "User" {$Filter = "(&(objectCategory=$objectType)(samAccountName=$objectName))"}
        "Computer" {$Filter = "(&(objectCategory=$objectType)(Name=$objectName))"}
        default {$Filter = "(&(objectCategory=$objectType)(samAccountName=$objectName))"}
        }
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $Filter
    ($objSearcher.FindOne()).GetDirectoryEntry()
}

$GlobalHash.UserADObject = GetADObject -objectName $env:username -objectType "User"
$GlobalHash.ComputerADObject = GetADObject -objectName $env:computername -objectType "Computer"


#endregion

#region GUI
Add-Type -AssemblyName System.Windows.Forms
#MainWindow
$MainWindow = New-Object system.Windows.Forms.Form
$MainWindow.Text = "Wolcott, Wood, and Taylor Inc."
$MainWindow.BackColor = "#6e90be"
$MainWindow.Width = 560
$MainWindow.Height = 560
$MainWindow.StartPosition = "CenterScreen"
$MainWindow.Icon = $GlobalHash.Icon
$MainWindow.AutoSize = $true
#Logo
$PictureBox2 = New-Object system.windows.Forms.PictureBox
$PictureBox2.Width = 350
$PictureBox2.ImageLocation = "http://www.wwtps.com/logos/WWT UoI PBG_Blue 350x120.png"
$PictureBox2.Height = 120
$PictureBox2.Width = 350
$PictureBox2.Height = 120
$PictureBox2.location = new-object system.drawing.point(100,20)
$MainWindow.controls.Add($PictureBox2)
#Welcom Message
$results_label = New-Object system.windows.Forms.Label
$results_label.Text = 'Do not close this window till a "Completed" message is shown.'
$results_label.AutoSize = $true
$results_label.Width = 25
$results_label.Height = 10
$results_label.location = new-object system.drawing.point(80,140)
$results_label.Font = "Microsoft Sans Serif,10,style=Bold,Underline"
$MainWindow.controls.Add($results_label)
#TextBox
$results_Text = New-Object System.Windows.Forms.RichTextBox 
$results_Text.Multiline =$true
$results_Text.Width = 450
$results_Text.Height = 300
$results_Text.location = new-object system.drawing.point(50,160)
$results_Text.Font = "Microsoft Sans Serif,10"
$results_Text.ScrollBars = "Both"
$results_Text.ForeColor = [Drawing.Color]::Black
$results_Text.SelectionStart = $results_Text.Text.Length
$MainWindow.controls.Add($results_Text)
	#region adding buttons
# $Actions = New-Object system.windows.Forms.Label
# $Actions.Text = "Actions"
# $Actions.AutoSize = $true
# $Actions.Width = 25
# $Actions.Height = 10
# $Actions.location = new-object system.drawing.point(15,75)
# $Actions.Font = "Microsoft Sans Serif,10,style=Bold,Underline"
# $MainWindow.controls.Add($Actions)

# $Drives = New-Object system.windows.Forms.Button
# $Drives.Text = "Drives"
# $Drives.Width = 80
# $Drives.Height = 32
# $Drives.location = new-object system.drawing.point(10,110)
# $Drives.Font = "Microsoft Sans Serif,10"
# $MainWindow.controls.Add($Drives)

# $button11 = New-Object system.windows.Forms.Button
# $button11.Text = "Printers"
# $button11.Width = 80
# $button11.Height = 29
# $button11.location = new-object system.drawing.point(10,159)
# $button11.Font = "Microsoft Sans Serif,10"
# $MainWindow.controls.Add($button11)

# $setting_Button = New-Object system.windows.Forms.Button
# $setting_Button.Text = "Settings"
# $setting_Button.Width = 80
# $setting_Button.Height = 29
# $setting_Button.location = new-object system.drawing.point(10,200)
# $setting_Button.Font = "Microsoft Sans Serif,10"
# $MainWindow.controls.Add($setting_Button)
#endregion
#endregion


#region functions	
# Check for error getting user-name
	If ($GlobalHash.UserID -eq "")
	{
	$results_Text.Text += ("Logon script failed - " + $GlobalHash.StrContact)
# Call Cleanup
	}
	else 
	{
	$results_Text.Text += ($GlobalHash.UserADObject.givenname + " you are logged onto " + $GlobalHash.ComputerADObject.name)
	}

#Find mapped drives and printers
    
    ForEach ($printer in $GlobalHash.MappedPrinters) 
    {
               
        #If ($printer.sharename = $null)
          #{   
            # {
           #  $results_Text.Text += ("Printer is not mapped")
            # $results_Text.ForeColor = [Drawing.Color]::Red   
             #}
       #else 
        #     {
         #      $results_Text.Text +=($GlobalHash.NewLine + "You may print to: " + $printer.sharename)
          #     $results_Text.ForeColor = [Drawing.Color]::Green
           #  }   
       # }
    

    }




#endregion
	

[void]$MainWindow.ShowDialog()
$MainWindow.Dispose()
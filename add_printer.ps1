Import-Module $env:SyncroModule

# Created by Steve Grabowski @ SoHo Integration
# Script to install Printer with Powershell (using Syncro MSP - but can be adapted to any RMM)
# Make sure to create the .zip file that has the INF file and all referenced files
# This zip file needs to unzip without sub dir's.  the INF file has the 'Printer Driver Name' as well.

$IPAddress = "192.168.xx.xx"
$PrintDriverName = "KONICA MINOLTA Universal V4 PCL" # This is from the INF file
$PrinterNiceName = "Nice Name of Printer"
$PrinterLocation = "Printer Location"
$DriverZipFile = "KMC4050" # leave off the .zip extension - change name to the name of your zip file
$DriverINF = "KOBxxK__01.inf" # Change this to the name of the .INF file
$TempLocation = "c:\windows\temp"

# Check if printer is already installed, if it is, then skip
$pname = get-printer
foreach($i in $pname){
    if($i.name -eq "$PrinterNiceName"){
        $findPrinter = $true
    }
}
if($findprinter){
    write-host "$PrinterNiceName is already installed" # For auditing purposes
} else {
#install printer
    # Expand Archive to $env:temp\kmC4050_Drivers
            expand-archive $env:temp\$DriverZipFile.zip -destinationpath $env:temp\"$DriverZipFile"_Drivers -Force
            
            # Use PNPUtil.exe to add the driver to the driver store.  ALL other referenced dll's, etc. need to be in the same folder as the .inf file
            pnputil.exe /add-driver $env:temp\"$DriverZipFile"_Drivers\$DriverINF
            
            # Add Printer Port if it does not exist
            $portExists = Get-Printerport -Name "IP_$IPAddress" -ErrorAction SilentlyContinue
            if (-not $portExists) {
                Add-PrinterPort -Name "IP_$IPAddress" -PrinterHostAddress "$IPAddress"
            }
            # This will make it show up in drivers in printer manager
            Add-PrinterDriver -name "$PrintDriverName"
            
            # Add Printer Driver that has been staged with PNPUTIL
            Add-Printer -DriverName "$PrintDriverName" -Name "$PrinterNiceName" -Location "$PrinterLocation" -PortName "IP_$IPAddress"
}
        

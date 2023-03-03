Import-Module $env:SyncroModule

$myVersion = get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
if($myVersion.displayversion -ne '22H2'){
    write-host "Not at 22H2, need to install update"

    $dir = "$env:temp\packages"
    if(test-path -path $dir){
        write-output "Folder exists, skip creation"
        Log-Activity -Message "Windows 10 22H2 Upgrade Started" -EventName "Windows Upgrade"
    } else {
        mkdir $dir 
    }


    $webClient = New-Object System.Net.WebClient 
	$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
    $file = "$dir\Win10Upgrade.exe"
    $downloadResults = $webClient.DownloadFile($url,$file) 
	$runProcessResults = Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

} else {
    write-host "Features up to date!"
}

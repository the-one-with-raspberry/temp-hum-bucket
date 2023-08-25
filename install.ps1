$isAdmin = ([Security.Principal.WindowsPrincipal] ` [Security.Principal.WindowsIdentity]::GetCurrent() ` ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Script needs to be ran as administrator."
    Pause
    exit
}
$devices = Get-PSDrive | Where-Object { ($_.Root -like "?:\") -and ($_.CurrentLocation -eq "") -and ($_.Used -ne "") }
$dev = ""
function Get-InputDevName {
    $tempDev = Read-Host "Drive name (example: D:)"
    if (($tempDev -notlike "?:") -and ($tempDev -notlike ":?\")) {
        Write-Host "Device name format not correct."
        Get-InputDevName
    }
    if ($Script:devices.Root.IndexOf($tempDev + "\") -eq -1) {
        Write-Host "Device name not correct."
        Get-InputDevName
    }
    else {
        $Script:dev = $tempDev + "\"
    }
}
Get-InputDevName
Write-Host $dev
$installConfirm = ""
function Get-ConfirmationInstall {
    $Script:installConfirm = Read-Host "Are you sure you want to continue? (This will take up ~2.2gb of storage space and will overwrite the SD card!) (y/n)"
    if ($installConfirm -eq "n") {
        exit 0
    }
    elseif ($installConfirm -ne "y") {
        Write-Host "Invalid Option."
        Get-ConfirmationInstall
    }
}

Invoke-WebRequest -Uri "https://s3.amazonaws.com/devicecfg.newmoon.io/images/raspios-lite-firstboot/2023-02-21-raspios-bullseye-armhf-lite-firstboot.img.xz" -OutFile "TempInstaller.zip"
mkdir temp-7z
Invoke-WebRequest -Uri "https://7-zip.org/a/7zr.exe" -OutFile ".\temp-7z\7z.exe"
.\temp-7z\7z.exe x TempInstaller.zip -otempinstall
Remove-Item -Path ".\temp-7z" -Recurse
Remove-Item -Path "TempInstaller.zip"
C:\Windows\System32\Dism.exe /Apply-Image /ImageFile:(Join-Path -Path (Get-Location) -ChildPath "tempinstall\2020-05-27-raspios-buster-armhf.img") /Index:1 /ApplyDir:(Get-Item $dev)
Remove-Item -Path "tempinstall"
$countrycode = ((curl "http://ip-api.com/json/$(curl ifconfig.me)") | ConvertFrom-Json).countryCode
$netconnname = (Get-NetConnectionProfile).Name
$netconnpass = (netsh.exe wlan show profile name="$($Script:netconnname)" key=clear)[32].Substring((("    Key Content            : ").Length))
"country=$($countrycode)`nupdate_config=1`nctrl_interface=/var/run/wpa_supplicant`n`nnetwork={`n`tscan_ssid=1`n`tssid=`"$($Script:netconnname)`"`n`tpsk=`"$($Script:netconnpass)`"`n}" | Out-File -LiteralPath (Join-Path -Path $dev -ChildPath "wpa_supplicant.conf")
"pimyhouse:`$6`$RRqhky76QNWIZo2f`$TwgoYjkENN/rG1.n25M2TNluzcbpUZMIG3DDg6LIe7uz1fs0AxLlqUE4C0otcX.vcDifsj.3hT9kQjC6NUrxQ/" | Out-File -LiteralPath (Join-Path -Path $dev -ChildPath "userconf.txt")
$internetname = Read-Host "What do you want the Raspberry Pi's internet name name to be? (you can access it through `"http://temphumsensor(whatever you said)`")"
Add-Content -Path .\firstboot.sh -Value "sudo raspi-config nonint do_hostname temphumsensor$($internetname)`nsudo reboot"
Write-Host "`aInstall completed. Take the SD card out and insert it into the Raspberry Pi, then connect a micro USB cable to the port that says `"PWR IN`"."
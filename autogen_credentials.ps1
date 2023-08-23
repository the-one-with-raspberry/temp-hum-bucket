param (
    [Parameter()]
    [String]$dev
)
$countrycode = ((curl "http://ip-api.com/json/$(curl ifconfig.me)") | ConvertFrom-Json).countryCode
$netconnname = Get-NetConnectionProfile
$netconnname = $netconnname.Name
$netconnpass = netsh.exe wlan show profile name="$($Script:netconnname)" key=clear
$netconnpass = $netconnpass[32].Substring(("    Key Content            : ".Length))
"country=$($countrycode)`nupdate_config=1`nctrl_interface=/var/run/wpa_supplicant`n`nnetwork={`n`tscan_ssid=1`n`tssid=`"$($Script:netconnname)`"`n`tpsk=`"$($Script:netconnpass)`"`n}" | Out-File -LiteralPath (Join-Path -Path $dev -ChildPath "wpa_supplicant.conf")
"pimyhouse:`$6`$RRqhky76QNWIZo2f`$TwgoYjkENN/rG1.n25M2TNluzcbpUZMIG3DDg6LIe7uz1fs0AxLlqUE4C0otcX.vcDifsj.3hT9kQjC6NUrxQ/" | Out-File -LiteralPath (Join-Path -Path $dev -ChildPath "userconf.txt")
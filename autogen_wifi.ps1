param (
    [Parameter()]
    [String]$dev
)
$netconnname = Get-NetConnectionProfile
$netconnname = $netconnname.Name
$netconnpass = netsh.exe wlan show profile name="$($Script:netconnname)" key=clear
$netconnpass = $netconnpass[32].Substring(("    Key Content            : ".Length))
"network={`n`tssid=`"$($Script:netconnname)`"`n`tpsk=`"$($Script:netconnpass)`"`n}" | Out-File -LiteralPath (Join-Path -Path $dev -ChildPath "wpa_supplicant.conf")
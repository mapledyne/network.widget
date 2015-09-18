#!/bin/bash

# Network status

iconGood="<i class='fa fa-check-circle green'></i>"
iconAlert="<i class='fa fa-times-circle red'></i>"
iconWifi="<i class='fa fa-wifi'></i>"
iconWorld="<i class='fa fa-globe'></i>"
iconRoute=" <i class='fa fa-sign-out blue'></i>"

#publicIP=$(curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
publicIP=$(curl -s http://icanhazip.com)

# Uses the airport command line utility to get the current SSID
currentNetwork=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F: '/ SSID: / {print $2}' | sed -e 's/SSID: //' | sed -e 's/ //')
# If the current network does not match this, it will show as red text
desiredNetwork=("PoohCorner" "712-100")

array_contains() {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

array_contains desiredNetwork "${currentNetwork}" && safeNetwork=1 || safeNetwork=0


wifiOrAirport=$(/usr/sbin/networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)')
wirelessDevice=$(/usr/sbin/networksetup -listallhardwareports | awk "/$wifiOrAirport/,/Device/" | awk 'NR==2' | cut -d " " -f 2)
wirelessIP=$(ipconfig getifaddr $wirelessDevice)
#wiredDevice=$(networksetup -listallhardwareports | grep -A 1 "Port: Display Ethernet" | sed -n 's/Device/&/p' | awk '{print $2}')
wiredDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Thunderbolt|Ethernet)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)

defaultRoute=$(route -n get default | grep -o "interface: .*" | awk '{print $2}')

wiredIcon=""
wirelessIcon=""

if [ "$defaultRoute" == "$wiredDevice" ]; then wiredIcon=$iconRoute; fi
if [ "$defaultRoute" == "$wirelessDevice" ]; then wirelessIcon=$iconRoute; fi

#----------FUNCTIONS---------
getWirelesstNetworkAndDisplayIp()
#################################
{
# If the current network does not equal the desired network, then
if [ "$safeNetwork" != "1" ];then
echo "<tr><td><span class='red'>$iconWifi</span> Network SSID</td><td><span class='red'>$currentNetwork</span></td></tr>"
echo "<tr><td><span class='red'>$iconWifi</span> Wireless IP</td><td><span class='red'>$wirelessIP${wirelessIcon}</span></td></tr>"
else
        echo "<tr><td><span class='green'>$iconWifi</span> Network SSID</td><td><span class='green'>$currentNetwork</span></td></tr>"
echo "<tr><td class=good><span class='green'>$iconWifi</span> Wireless IP (en0)</td><td><span class='green'>$wirelessIP${wirelessIcon}</span></td></tr>"
fi
}


displayEthernetIp()
###################
{
# If the Ethernet adapter is not equal to a null value (no IP address), then

 wiredIP=$(ipconfig getifaddr $1)
if [ ! -z "${wiredIP}" ];then
        icon=""

        if [ "$defaultRoute" == "$1" ]; then icon=$iconRoute; fi
        echo "<tr><td>$iconGood Ethernet IP ($1)</td><td><span class='green'>$wiredIP${wiredIcon}</span> $icon</td></tr>"
else
        echo "<tr><td>$iconAlert Ethernet IP ($1)</td><td><span class='red'>INACTIVE</span></td></tr>"
fi

}
#--------------------------------
#----------BEGIN SCRIPT----------
#--------------------------------

echo "<h1>NETWORK</h1>
<table>"
getWirelesstNetworkAndDisplayIp
#displayEthernetIp()

for i in $wiredDevice; do
	displayEthernetIp $i
done
if [ ! -z "${publicIP}" ];then
  echo "<tr><td><span class='green'>$iconWorld</span> Public IP</td><td><span class='green'>$publicIP</span></td></tr>"
else
  echo "<tr><td><span class='red'>$iconWorld</span> Public IP</td><td><span class='red'>Unavailable</span></td></tr>"
fi

echo "</table>"

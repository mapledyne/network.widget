#!/bin/bash

# Network status


# Uses the airport command line utility to get the current SSID
currentNetwork=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F: '/ SSID: / {print $2}' | sed -e 's/SSID: //' | sed -e 's/ //')
# If the current network does not match this, it will show as red text
desiredNetwork="712-100"

wifiOrAirport=$(/usr/sbin/networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)')
wirelessDevice=$(/usr/sbin/networksetup -listallhardwareports | awk "/$wifiOrAirport/,/Device/" | awk 'NR==2' | cut -d " " -f 2)
wirelessIP=$(ipconfig getifaddr $wirelessDevice)
#wiredDevice=$(networksetup -listallhardwareports | grep -A 1 "Port: Display Ethernet" | sed -n 's/Device/&/p' | awk '{print $2}')
wiredDevice=$(networksetup -listallhardwareports | grep -Ei -A 1 '(Thunderbolt|Ethernet)' | grep en | sed -n 's/Device/&/p' | awk '{print $2}' | sort)

defaultRoute=$(route -n get default | grep -o "interface: .*" | awk '{print $2}')

wiredIcon=""
wirelessIcon=""

if [ "$defaultRoute" == "$wiredDevice" ]; then wiredIcon="🔹"; fi
if [ "$defaultRoute" == "$wirelessDevice" ]; then wirelessIcon="🔹"; fi

#----------FUNCTIONS---------
getWirelesstNetworkAndDisplayIp()
#################################
{
# If the current network does not equal the desired network, then
if [ "$currentNetwork" != "$desiredNetwork" ];then
echo "<tr><td>❗ Network SSID</td><td><span class='red'>$currentNetwork</span></td></tr>"
echo "<tr><td>❗ Wireless IP</td><td><span class='red'>$wirelessIP${wirelessIcon}</span></td></tr>"
else
        echo "<tr><td>✅ Network SSID</td><td><span class='green'>$currentNetwork</span></td></tr>"
echo "<tr><td>✅ Wireless IP (en0)</td><td><span class='green'>$wirelessIP${wirelessIcon}</span></td></tr>"
fi
}


displayEthernetIp()
###################
{
# If the Ethernet adapter is not equal to a null value (no IP address), then

 wiredIP=$(ipconfig getifaddr $1)
if [ ! -z "${wiredIP}" ];then
        selfAssigned=$( echo $wiredIP | grep "169\.254\.[0-9]\{1,3\}\.[0-9]\{1,3\}" )

        if [ ! -z $selfAssigned ]; then
            echo "<tr><td>✅ Ethernet IP ($1)</td><td><span class='green'>$wiredIP${wiredIcon}</span></td></tr>"
        else
            echo "<tr><td>✅ Ethernet IP ($1)</td><td><span class='green'>$wiredIP${wiredIcon}</span></td></tr>"
        fi
else
        echo "<tr><td>🔴 Ethernet IP ($1)</td><td><span class='red'>INACTIVE</span></td></tr>"
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
echo "</table>"
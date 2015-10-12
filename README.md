# network.widget

This widget is adapted from a script that [mapledyne](http://github.com/mapledyne) created for use in GeekTool.  He passed it to me, and I made some modifications.

Recently I have switched to using [Übersicht](http://tracesof.net/uebersicht/), and this script had been useful to me, so I brought it over and made it into an Übersicht widget.

Basically it displays a quick listing on your desktop of network interfaces and what their states and IP addresses if any, are.  Thins are color coded for quick reference.

To use this script you need two things
1. [This FontAwesome widget](http://github.com/thewellington/fontawesome.widget) in your widgets directory.
2. you need to edit the `safeNetworksArray` on line 8 of `network.sh` to match the array of SSIDs that you consider to be safe.

Also if you don't want to use fontawesome, and instead have other icons you would like to use, make them available to the set of variables in the `fontawesome classes` on lines 10-15 of `network.sh`.


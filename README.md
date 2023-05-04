REQUIREMENTS
This script written for Ubuntu server, but it probably works just fine with Linux distros, as well as MacOS. 
Yes, I am aware of SirToffski's Wireguard-Ligase repo. This is something I wanted to learn (and do) myself.

IMPORTANT
This is a simple script for generating [Peer] private, public, and shared keys, and [Peer] config files for a Wireguard VPN installation. 
It assumes you already have Wireguard installed on your system, have generated private and public keys for
your Wireguard server, have created the /etc/wireguard/configs and etc/wireguard/keys directories, as well as the 
wg0.conf file with the [Interface] already configured. In the future I'd like to develop functionality to check and prompt the
user for these items if they have not already been created and configured. 


HOW TO USE
1. Change Line 50 in the script echo "Endpoint = <server_public_ip_address>:51820" >> $device_conf
	>> <server_public_ip_address> should be the public-facing address of your server or LAN, or 
	     the DNS name where it is located (if it's the public IP of your home router, you should have forwarded
	     ports already). if you have a DNS name but it points to your home address, make sure you have 
	     set up DDNS.
2. You can save the file anywhere, but I typically save it in my /Users/username/ directory. 
3. Make script executable by entering into your terminal: sudo chmod +x /path/to/wireguard-peer-setup.sh
4. Set an alias in your profile configuation. 
	>> alias add-wireguard-peer="sudo ./wireguard-peer-setup.sh
5. Refresh profile
6. Run script via alias. 
7. Enter name of the peer device (mylinux or device1). 
8. Import the peer device configuration onto the peer device wireguard client
	>> You can use the official wireguard application for the OS you're using
	>> You can also configure it on the peer device's command line, but that's not in scope here. 
9. Connect to your wireguard VPN. 

NOTES:

1. This script uses predefined VLAN and private ip subnets, which you can (should?) change. 
	>> See item 4. below
   
 TROUBLESHOOTING WIREGUARD CONNECTIVITY

1. Ensure the machine you have Wireguard installed on is synced to the correct time. 
		>> Time sync issues will cause connection problems.
2. Be sure to forward packets in your systctl.conf file.
		>> Likely located in your /etc folder. 
		>> Uncomment the following lines: 
				net.ipv4.ip_forward=1
   				net.ipv6.conf.all.forwarding=1
   		>> To apply changes, type into terminal: sudo systctl -p 
 3. When forwarding ports on your router to your device where Wireguard is installed, make sure you're forwarding the correct protocol. 
 		>> UDP, not TCP. Please double-check this and save yourself the headache. The dfault is 51820, though you can change if you like. 
 4. If the LAN you're on has the same private ip address space as your remote LAN, there could be conflicts. I would change the private ip 
	 range of your remote LAN to something a little less common. 192.168.0.0/24 is common on home routers, for example.
	 You can find the follwing reserved subnets
	 for local ip ranges at https://www.rfc-editor.org/rfc/rfc1918. 
	 
 	 	 10.0.0.0        -   10.255.255.255  (10/8 prefix)
    	 172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
     	 192.168.0.0     -   192.168.255.255 (192.168/16 prefix)
  
  5. Make sure your wg0.conf [Interface] is a /24 subnet and your peers are a /32 subnet. /24 subnet peers will cause collisions. 
  6. If this script isn't working for you and you decide to generate keys and set up your configurations manually, don't forget to 
  	  restart/refresh your wireguard service for changes to take effect!
  
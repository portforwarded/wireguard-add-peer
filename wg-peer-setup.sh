#!/usr/bin/bash

# Get device name from user input
echo "Enter device name: "
read device_name

# Set variables for file names and paths
config_dir="/etc/wireguard/configs"
keys_dir="/etc/wireguard/keys"
server_pub_key="$keys_dir/server.pub"
device_priv_key="$keys_dir/$device_name.key"
device_pub_key="$keys_dir/$device_name.pub"
psk="my_psk"
shared_key="$keys_dir/$device_name-shared.key"
device_conf="$config_dir/$device_name.conf"

# Get the next IP address in the subnet by counting the number of configuration files in the /etc/wireguard/configs directory
ip_address_prefix="10.74.166"
subnet="32"
ip_address_suffix=$(( $(ls $config_dir | wc -l) + 2 )) # Add 2 to account for the gateway (1) and this new peer

# Generate private key for device
wg genkey | sudo tee $device_priv_key >/dev/null
echo "Created device private key."
sudo chmod 600 $device_priv_key
echo "Modified device private key permissions."

# Generate public key for device
sudo wg pubkey < $device_priv_key | sudo tee $device_pub_key >/dev/null
echo "Created device public key."
sudo chmod 600 $device_pub_key
echo "Modified public key permissions."

# Generate pre-shared key
wg genpsk | sudo tee $shared_key >/dev/null
echo "Created peer shared key."
sudo chmod 600 $shared_key
echo "Modfied shared key permissions."


# Create device configuration file
echo "[Interface]" > $device_conf
echo "Address = $ip_address_prefix.$ip_address_suffix/$subnet" >> $device_conf
echo "PrivateKey = $(cat $device_priv_key)" >> $device_conf
echo "DNS = 1.1.1.1" >> $device_conf
echo "" >> $device_conf
echo "[Peer]" >> $device_conf
echo "PublicKey = $(cat $server_pub_key)" >> $device_conf
echo "PresharedKey = $(cat $shared_key)" >> $device_conf
echo "Endpoint = <server_public_ip_address>:51820" >> $device_conf
echo "AllowedIPs = 0.0.0.0/0, ::0/0" >> $device_conf
echo "Created device config file."

# Set permissions of device configuration file
chmod 600 "$device_conf"
echo "Modified device config file permissions."

# Add peer to wg0.conf
echo "" >> /etc/wireguard/wg0.conf
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = $(cat $device_pub_key)" >> /etc/wireguard/wg0.conf
echo "PresharedKey = $(cat $shared_key)" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = $ip_address_prefix.$ip_address_suffix/$subnet" >> /etc/wireguard/wg0.conf

echo "Added peer to wg0.conf file."
sudo systemctl restart wg-quick@wg0.service
echo "Applied new configuration and restarted Wireguard service."
echo "Add peer configuration file to device and connect to VPN."
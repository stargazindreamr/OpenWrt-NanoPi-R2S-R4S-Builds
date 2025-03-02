#!/bin/ash
clear
# Argument validation check
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <description_or_user_1> <description_or_user_2> ..."
    exit 1
fi
echo "========================================================="
echo "|               Automated WireGuard Script              |"
echo "| Add Additional Set Number of Peers with Names and IDs |"
echo "========================================================="
echo ""
# Define Variables
echo -n "Defining variables... " 
export LAN="wglan"
export interface="10.0.5"
export DDNS="stargazindreamr.twilightparadox.com"
export WG_${LAN}_server_port="51820"
export WG_${LAN}_server_IP="${interface}.1"
export WG_${LAN}_server_firewall_zone="${LAN}"
#
export quantity="$#"
#
function last_peer_ID () {
cd "/etc/wireguard/networks/${LAN}/peers"
ls | sort -V | tail -1 | cut -d '_' -f 1
}
export peer_ID=$(last_peer_ID) ; export peer_ID=$((peer_ID+1))
function last_peer_IP () {
cd "/etc/wireguard/networks/${LAN}/peers"
peer=$(ls | sort -V | tail -1)
awk '/Address/' $peer/*.conf | cut -d '/' -f 1 | cut -d '.' -f 4
cd
}
export peer_IP=$(last_peer_IP) ; export peer_IP=$((peer_IP+1))
echo "Done"
echo "========================================================="
 
n=0
#while [ "$n" -lt ${quantity} ] ; 
#do
#	for username in ${user_1} ${user_2} # ${user_3} ${user_4}
for username in $@
do
	# Configure Variables
	echo "" 
	echo -n "Defining variables for '${peer_ID}_${LAN}_${username}'... " 
	eval "peer_ID_${username}=${peer_ID}"
	eval "peer_IP_${username}=${peer_IP}"
	 
	eval "peer_ID=\${peer_ID_${username}}"
	eval "peer_IP=\${peer_IP_${username}}"
	 
	eval "server_port=\${WG_${LAN}_server_port}"
	eval "server_IP=\${WG_${LAN}_server_IP}"
	echo "Done"
	echo "========================================================="
	 
	# Create directory for storing peers
	echo -n "Creating directory for peer '${peer_ID}_${LAN}_${username}'... " 
	mkdir -p "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}"
	echo "Done"
	echo "========================================================="
	 
	# Generate peer keys
	echo -n "Generating peer keys for '${peer_ID}_${LAN}_${username}'... " 
	wg genkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key" >/dev/null 2>&1
	echo "Done"
	echo "========================================================="
	 
	# Generate Pre-shared key
	echo -n "Generating peer PSK for '${peer_ID}_${LAN}_${username}'... " 
	wg genpsk | tee "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk" >/dev/null 2>&1
	echo "Done"
	echo "========================================================="
	 
	# Add peer to server 
	echo -n "Adding '${peer_ID}_${LAN}_${username}' to WireGuard server... " 
	uci add network wireguard_wg_${LAN} >/dev/null 2>&1
	uci set network.@wireguard_wg_${LAN}[-1].public_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key)"
	uci set network.@wireguard_wg_${LAN}[-1].private_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key)"
	uci set network.@wireguard_wg_${LAN}[-1].preshared_key="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk)"
	uci set network.@wireguard_wg_${LAN}[-1].description="${peer_ID}_${LAN}_${username}"
	uci add_list network.@wireguard_wg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
	uci set network.@wireguard_wg_${LAN}[-1].route_allowed_ips='1'

	uci set network.@wireguard_wg_${LAN}[-1].endpoint_host=stargazindreamr.twilightparadox.com
	uci set network.@wireguard_wg_${LAN}[-1].endpoint_port=51820
	uci set network.@wireguard_wg_${LAN}[-1].persistent_keepalive='25'
	echo "Done"
	echo "========================================================="
	 
	# Create peer configuration
	echo -n "Creating config for '${peer_ID}_${LAN}_${username}'... " 
	cat <<-EOF > "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
	[Interface]
	Address = ${interface}.${peer_IP}/32
	PrivateKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key) # Peer's private key
	DNS = ${server_IP}
	 
	[Peer]
	PublicKey = $(cat /etc/wireguard/networks/${LAN}/${LAN}_server_public.key) # Server's public key
	PresharedKey = $(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk) # Peer's pre-shared key
	PersistentKeepalive = 25
	AllowedIPs = 192.168.1.0/24, 0.0.0.0/0, ::/0
	Endpoint = ${DDNS}:${server_port}
	EOF
	echo "Done"
	echo "========================================================="

	#file="$(cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf)"
	#echo $file

	file="/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
	echo $file
	echo "========================================================="
	cat $file
	echo "========================================================="
	echo "Done creating WireGuard peer '${peer_ID}_${LAN}_${username}'!"
	echo "========================================================="

	#file=`cat /etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf`
	#cat $file

	# Show the QR code to the user
	qrencode -t ansiutf8 < $file
	#qrencode -t ansiutf8 < "/etc/wireguard/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
	 
	# Increment variables by '1'_wglan_Alpha/
	peer_ID=$((peer_ID+1))
	peer_IP=$((peer_IP+1))
	n=$((n+1))
done
#done
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup wg_${LAN}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
/etc/init.d/firewall restart >/dev/null 2>&1
echo "Done"

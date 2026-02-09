## MikroTik WireGuard Configuration for Media Services VPN Hub
## RouterOS 7.20.6
##
## Architecture:
## Media Services (K8s) -> MikroTik (firefly_vpn) -> Privado VPN (privado_vpn) -> Internet

#######################
## 1. VPN HEADEND CONNECTION (Privado)
#######################

# Create WireGuard interface for Privado VPN
/interface wireguard
add name=privado_vpn mtu=1420 listen-port=51830 \
    private-key="mKlw1AmlgSFmjlt8Rmwz7nSFSttHo2Tkl1cJnFqjdHU="

# Add IP address assigned by Privado
/ip address
add address=100.64.32.242/32 interface=privado_vpn comment="Privado VPN IP"

# Add Privado peer
/interface wireguard peers
add interface=privado_vpn \
    public-key="KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=" \
    endpoint-address=91.148.240.47 endpoint-port=51820 \
    allowed-address=0.0.0.0/0 \
    persistent-keepalive=25s \
    comment="Privado AMS-032"

#######################
## 2. MEDIA SERVICES VPN SERVER
#######################

# Create WireGuard interface for media services (server mode)
/interface wireguard
add name=firefly_vpn mtu=1420 listen-port=51880 \
    comment="Media Services VPN Hub"

# Generate private key (save the output, you'll need it)
# Run: /interface wireguard print proplist=public-key where name=firefly_vpn
# This will show the public key to use in service configs

# Add IP address for media VPN network
/ip address
add address=10.99.0.1/24 interface=firefly_vpn comment="Firefly K8s Cluster VPN Gateway"

#######################
## 3. MEDIA SERVICE PEERS
#######################

# You need to generate private keys for each service
# For now, add peers with their public keys (update after generating)

/interface wireguard peers
add interface=firefly_vpn \
    allowed-address=10.99.0.10/32 \
    comment="sabnzbd"

/interface wireguard peers
add interface=firefly_vpn \
    allowed-address=10.99.0.11/32 \
    comment="qbittorrent"

/interface wireguard peers
add interface=firefly_vpn \
    allowed-address=10.99.0.12/32 \
    comment="jackett"

/interface wireguard peers
add interface=firefly_vpn \
    allowed-address=10.99.0.13/32 \
    comment="prowlarr"

/interface wireguard peers
add interface=firefly_vpn \
    allowed-address=10.99.0.14/32 \
    comment="nzbhydra2"

#######################
## 4. ROUTING & NAT
#######################

# Create routing table for VPN traffic
/routing table
add name=vpn_routing fib comment="VPN routing table"

# Mark connections from firefly_vpn
/ip firewall mangle
add chain=prerouting in-interface=firefly_vpn \
    action=mark-connection new-connection-mark=firefly_vpn_conn \
    comment="Mark firefly VPN connections"

# Mark packets from marked connections (for non-RFC1918 only)
/ip firewall mangle
add chain=prerouting connection-mark=firefly_vpn_conn \
    dst-address=!10.0.0.0/8 \
    action=mark-routing new-routing-mark=vpn_routing \
    comment="Route non-RFC1918 to VPN (10.0.0.0/8)"

/ip firewall mangle
add chain=prerouting connection-mark=firefly_vpn_conn \
    dst-address=!172.16.0.0/12 \
    action=mark-routing new-routing-mark=vpn_routing \
    comment="Route non-RFC1918 to VPN (172.16.0.0/12)"

/ip firewall mangle
add chain=prerouting connection-mark=firefly_vpn_conn \
    dst-address=!192.168.0.0/16 \
    action=mark-routing new-routing-mark=vpn_routing \
    comment="Route non-RFC1918 to VPN (192.168.0.0/16)"

# Add default route in VPN routing table
/ip route
add dst-address=0.0.0.0/0 gateway=privado_vpn routing-table=vpn_routing \
    comment="Default route via Privado VPN"

# NAT/Masquerade traffic going out via Privado
/ip firewall nat
add chain=srcnat out-interface=privado_vpn action=masquerade \
    comment="NAT media services via Privado VPN"

#######################
## 5. FIREWALL (Allow WireGuard)
#######################

# Allow WireGuard from internet (for remote service connections if needed)
/ip firewall filter
add chain=input protocol=udp dst-port=51880 \
    action=accept comment="Allow WireGuard firefly_vpn"

# Allow forwarding from firefly_vpn
/ip firewall filter
add chain=forward in-interface=firefly_vpn action=accept \
    comment="Allow media VPN forwarding"

#######################
## SETUP NOTES
#######################

# After applying this config:
# 1. Get the firefly_vpn public key:
#    /interface wireguard print proplist=public-key where name=firefly_vpn
#
# 2. Generate keypairs for each service (on your local machine):
#    wg genkey | tee privatekey | wg pubkey > publickey
#    Do this 5 times (sabnzbd, qbittorrent, jackett, prowlarr, nzbhydra2)
#
# 3. Update each peer with public-key parameter:
#    /interface wireguard peers set [find comment="sabnzbd"] public-key="<key>"
#
# 4. Test connectivity:
#    - From MikroTik: /ping 10.99.0.10 (after service is up)
#    - From service: ping 10.99.0.1
#    - Test VPN: curl ifconfig.me (should show Privado IP)
#
# 5. Monitor:
#    /interface wireguard peers print
#    /ip route print where routing-table=vpn_routing

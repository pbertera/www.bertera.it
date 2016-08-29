Title: VPN layer 3 con OpenSSH
Date: 2008-12-22 13:48
Author: admin
Tags: bash, ssh, vpn
Slug: vpn-layer-3-con-openssh
Status: published

Dalla versione 4.3 di OpenSSH è stato introdotto il supporto per
TUN/TAP. Questo sigifica che è possibile stabilire un tunnel cifrato tra
due peer o due (o piu) reti.  
[Questo](https://github.com/pbertera/ssh-vpn) script si
occupa di fare il discover dei device tun da utilizzare, assegnare gli
indirizzi e le rotte al tunnel (locali e sul peer remoto) ed eseguire
comandi aggiuntivi tramite un file di configurazione.

**[testvpn.conf](https://github.com/pbertera/ssh-vpn/blob/master/example.conf):**

```
SSH_OPTS="-i /home/pietro/.ssh/id_dsa" # optional: options for ssh command
RUSER=root  # user to login on remote peer
PEER=172.42.10.2 # ip of remote peer
RTUNADDR=10.10.100.2 # remote ip of tunnel
LTUNADDR=10.10.100.1 # local ip of tunnel
#LOCAL_TUN=tun0 #optional: static definition of local tun device
#REMOTE_TUN=tun1 #optional: static definition of remote tun device
REMOTE_NET=172.16.40.1 # remote network
ENABLE_PEER_IP_FORWARD=true # enable ip forwarding on remote host
TRY_LOAD_PEER_TUN_MOD=true # try loading tun/tap kernel module
BAILOUT_COMMAND="logger died"
# in POST_TUN_PEER_COMMAND and POST_TUN_LOCAL_COMMAND use ' instead " !!!
# $LOCAL_TUN is local tun device
# $REMOTE_TUN is remote tun device
POST_TUN_PEER_COMMAND='iptables -I FORWARD -i $REMOTE_TUN -j ACCEPT' # optional: command to execute on remote peer
POST_TUN_LOCAL_COMMAND='ip route add 192.168.6.0/24 via $RTUNADDR dev $LOCAL_TUN' # optional: command to execute on local peer
LOCAL_IP="ip" # optional: local ip command binary
REMOTE_IP="ip" # optional: remote ip command binary
SSH="ssh" # optional: ssh binary
```

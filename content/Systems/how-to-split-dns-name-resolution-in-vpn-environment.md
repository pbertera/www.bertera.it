Title: How to split DNS name resolution in VPN environment
Date: 2011-11-30 19:18
Author: admin
Tags: dns, openvpn, powerdns, scripting, vpn
Slug: how-to-split-dns-name-resolution-in-vpn-environment
Status: published

I'm in this situation:  
a VPN to remote concentrator that load many routes to private networks,
vpn server push DNS configuration via OpenVPN protocol (see
--dhcp-option DNS in openvpn(8) ).  
The scope of this post is to explain how you can use remote DNS pushed
by VPN concentrator only for certain zones.  
For accomplish this I used a local [PowerDNS](http://www.powerdns.com)
server and a little [OpenVPN](http://www.openvpn.net) up script:

When OpenVPN make the tunnel the up script create a custom
**forward-zones-file** used by PowerDNS. The script insert in the custom
file the remote zones and the dns server authoritative for these zones.

**PowedDNS configuration:**

```
[pietro@berta ~]$ grep -v ^\# /etc/pdns/pdns.conf | sed -e /^$/d
setuid=pdns
setgid=pdns
allow-recursion=127.0.0.1/8
negquery-cache-ttl=0
query-cache-ttl=0
 
[pietro@berta ~]$ grep -v ^\# /etc/pdns-recursor/recursor.conf | sed -e /^$/d
setuid=pdns-recursor
setgid=pdns-recursor
forward-zones-file=/etc/pdns-recursor/vpn-zones.conf
```

**OpenVPN configuration:**

```
[pietro@berta ~]$ grep ^up /etc/openvpn/my-vpn.conf
up /etc/openvpn/vpn-dns.sh up
down /etc/oprnvpn/vpn-dns.sh down
```

**the /etc/openvpn/vpn-dns.sh script:**

```
#!/bin/bash
 
zones="example.com remote.com my.internal.zone"
dns=dns

case $1 in
    up)
        for opt in ${!foreign_option_*}
        do
            eval "dns=${$opt#dhcp-option DNS }"
            if [ "$dns" != "dns" ]
            then
                echo ";; created by openvpn --up ${0} " >/tmp/vpn-zones.conf
                for zone in $zones; do
                    echo "+$zone=$dns" >> /tmp/vpn-zones.conf
                done
                mv -f /tmp/vpn-zones.conf /etc/pdns-recursor/
                rec_control reload-zones
                exit 0
            fi
        done
        ;;
 
    down)
        echo > /etc/pdns-recursor/vpn-zones.conf
        rec_control reload-zones
        ;;
    * )
        echo usage:
        echo "$0 [up|down]"
        ;;
esac
```

This script route DNS zones *example.com remote.com my.internal.zone* to
DNS server pushed by OpenVPN.

You can check the right configuration using dig end tcpdump on tunnel
interface to see correctly routed DNS query.  
In finish you must not forget to instruct your dhcp client to use
127.0.0.1 as a DNS server


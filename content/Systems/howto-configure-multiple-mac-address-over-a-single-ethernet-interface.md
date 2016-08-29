Title: Howto configure multiple mac address over a single ethernet interface
Date: 2011-10-04 18:01
Author: admin
Tags: iptables, linux, networking, routing
Slug: howto-configure-multiple-mac-address-over-a-single-ethernet-interface
Status: published

I up against this problem on a server hosted by Hetzner.My server is a
virtual hypervisor containing several virtual machines.The Hetzner's
politics is to statically associate a public IP to a single mac address,
is therefore impossible to have multiple IP address on a single ethernet
device.  Observing this rule you can associate only one virtual machine
with one public IP, and you cannot create a firewall with all public IPs
attested on public interface and private interfaces attached to a
vSwitchs.

To solve the problem you can use the macvlan module. Macvlan allow to
create indipendent logical devices over a single ethernet device. In
this way you have three (logical) ethernet device with three IPs and
three mac address over a single physical device. This solve the
addressing problem but slightly complicates routing and NAT.

### Configuration example:  

**Public IPs:**  
  
A.A.A.A associated mac address: aa:aa:aa:aa:aa:aa  
  
B.B.B.B associated mac address: bb:bb:bb:bb:bb:bb  
  
C.C.C.C associated mac address: cc:cc:cc:cc:cc:cc  
  
External interface: eth0  

**Gateway:**  
X.X.X.X

**Internal Subnets:**  
a.a.a.0/24 (eth1)  
b.b.b.0/24 (eth2)  
c.c.c.0/24 (eth3)

**Firewall IPs on internal subnets:**  
eth1: a.a.a.254  
eth2: b.b.b.254  
eth3: c.c.c.254

### Network schema:  

I want to map the outgoing connections in this way:

|**Origin subnet**|**Public IP**|
|-----------------|-------------|
|a.a.a.0/24|A.A.A.A|
|b.b.b.0/24|B.B.B.B|
|c.c.c.0/24|C.C.C.C|

### Macvlan interface creation

1. set-up link on physical device:

```
    ip link set up dev eth0
```

2. create logical interfaces:

```
    ip link add link eth0 dev peth0 type macvlan address aa:aa:aa:aa:aa:aa
    ip link add link eth0 dev peth1 type macvlan address bb:bb:bb:bb:bb:bb
    ip link add link eth0 dev peth2 type macvlan address cc:cc:cc:cc:cc:cc
```

3. Assign ip address and activate link:

```
    ip addr add A.A.A.A/26 dev peth0
    ip addr add B.B.B.B/26 dev peth1
    ip addr add C.C.C.C/26 dev peth2
    ip link set up dev peth0
    ip link set up dev peth1
    ip link set up dev peth2
```

4. Normally configure the internal interfaces (eth1, eth2 eth3):

```
    ip addr add a.a.a.245/24 dev eth1
    ip addr add b.b.b.245/24 dev eth2
    ip addr add b.b.b.245/24 dev eth3
    ip link set up dev eth1
    ip link set up dev eth2
    ip link set up dev eth3
```

5. This is the routing situation:

```
# ip route sh
127.0.0.0/8 dev lo  proto kernel  scope link  src 127.0.0.1
a.a.a.0/24 dev eth1  proto kernel  scope link  src a.a.a.254
a.a.a.0/24 dev eth2  proto kernel  scope link  src b.b.b.254
a.a.a.0/24 dev eth3  proto kernel  scope link  src c.c.c.254
A.A.A.A/26 dev peth0  proto kernel  scope link  src A.A.A.A
B.B.B.B/26 dev peth1  proto kernel  scope link  src B.B.B.B
C.C.C.C/26 dev peth2  proto kernel  scope link  src C.C.C.C
```

6. You must create a routing table for all outgoing interface:

```
    echo "500 ipA" >> /etc/iproute2/rt_tables
    echo "600 ipB" >> /etc/iproute2/rt_tables
    echo "700 ipC" >> /etc/iproute2/rt_tables
```

7. Add a "catch all" routing table:

```
    echo "1000 catch_all" >> /etc/iproute2/rt_tables
```

8. Add gateways for tables:

```
    ip route add default via X.X.X.X dev peth0 table ipA
    ip route add default via X.X.X.X dev peth1 table ipB
    ip route add default via X.X.X.X dev peth1 table ipC
    ip route add default via X.X.X.X dev peth0 table catch_all
```

9. Add routing policy for internal subnet. Note that the priority must
be greater than the priority used for the normal and default tables (for
show all rules: ip rule show )

```
    ip rule add from a.a.a.0/24 lookup ipA pref 60000
    ip rule add from b.b.b.0/24 lookup ipB pref 60001
    ip rule add from c.c.c.0/24 lookup ipC pref 60002
```

10. Add routing policy for local IPs:

```
    ip rule add from A.A.A.254 lookup ipA pref 60010
    ip rule add from B.B.B.254 lookup ipB pref 60011
    ip rule add from C.C.C.254 lookup ipC pref 60012
```

11. Add a catch all routing policy (with preference greater than all):

```
    ip rule add from all lookup catch_all pref 70000
```

12. Configure the NAT:

```
    iptables -t nat -I POSTROUTING -o peth0 -s a.a.a.0/24 -j SNAT --to-source A.A.A.A
    iptables -t nat -I POSTROUTING -o peth1 -s b.b.b.0/24 -j SNAT --to-source B.B.B.B
    iptables -t nat -I POSTROUTING -o peth2 -s c.c.c.0/24 -j SNAT --to-source C.C.C.C
```

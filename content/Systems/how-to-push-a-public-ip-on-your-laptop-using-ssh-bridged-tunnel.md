Title: How to push a public IP on your laptop using SSH bridged tunnel
Date: 2012-03-04 23:49
Author: admin
Tags: routing, ssh, vpn
Slug: how-to-push-a-public-ip-on-your-laptop-using-ssh-bridged-tunnel
Status: published

In my [previous
post](http://www.bertera.it/index.php/2008/12/22/vpn-layer-3-con-openssh/ "VPN layer 3 con OpenSSH") I
talked about Layer 3 VPN feature of OpenSSH (starting from version
4.3).  
Now, I'm talking about bridged VPN or Layer 2 VPN. With this feature
you can create a virtual network device that, through the encrypted
tunnel, is connected on the same network segment of remote server. In
fact the VPN acts as a network switch connecting local virtual device
with remote device in same ethernet network.

With this setup your SSH client will connect to remote server and start
forwarding packet between local end remote TUN/TAP device.  
All packets are forward through the encrypted SSH tunnel.

using **-o Tunnel=ethernet** instead of ***-o
Tunnel=point-to-point*** ssh process try to use a tap device and
forwards all ethernet frames (layer 2). You can specify TUN/TAP local
and remote device index with ***-w*** option:

This command: `ssh -o Tunnel=ethernet -w 0:1 host.example.com`
establish an ssh connection to host.example.com and forwards all ethernet
frames from local tap0 to remote tap1 and vice-versa.  
If tap0 and tap1 doesn't exist ssh will try to create.

In order to setup a public IP on your laptop you need to create a bridge
between remote remote public ethernet device and remote TUN/TAP device.
Below the accomplishment step for this task:

Assuming that this is the public network configuration:

**Public IP:** 78.47.249.187  
**Public Network:** 78.47.249.160  
**Public Gateway:** 78.47.249.190  
**Laptop Public IP:** 78.47.249.187

**On server side:**

* create a bridge: `brctl addbr br0`
* create the remote tap device: `tunctl -t tap0`
* add devices to bridge: `brctl addif br0 eth0 && brctl addif br0 tap0`
* setup the remote public IP address on bridge interface: `ip addr add  78.47.249.187/27 dev br0`
* setup link and promiscuous mode: `ip link set up promisc on dev tap0  && ip link set up promisc on dev eth0`
* setup default gateway: `ip route add default via  78.47.249.190`
* Permit tunnel on ssh server: add "**PermitTunnel yes**" on your sshd_config sshd configuration file

Now the public machine must be connected to public network and
reachable.

**On client side:**

* connect your laptop to server and create the tunnel `ssh -o Tunnel=ethernet -w 0:0 root@78.47.249.187`
* add public ip to your client and setup link: `ip addr add  78.47.249.188/27 dev tap0 && ip link set up dev tap0`

Now your laptop is directly connected to public remote network through
tap0 device.  
Following steps are needed only  if you  need to substitute your
gateway with public gw:

* setup a static route to remote server (you need to know your current
default gw): `ip route add 78.47.249.187 via my.old.def.gw`
* setup the new default gw: `ip route del default via my.old.def.gw && ip route add default via 78.47.249.190 dev tap0`

**Tips:**

* You can automate all client task with a simple bash script
* *-u* and *-g* tunctl options permit to manage TUN/TAP device with an unprivileged user
* use ssh public key authentication and a dedicated unprivileged user
* *-NTCf -o ServerAliveInterval=60* ssh options are your friends
* following the configuration files for automatic and reboot persistent configuration on server side (for RedHat based distro):

**/etc/sysconfig/network-scripts/ifcfg-br0**

```
DEVICE="br0"
ONBOOT="yes"
TYPE=Bridge
BOOTPROTO=none
IPADDR=78.47.249.187
PREFIX=27
GATEWAY=78.47.249.190
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System Bridge"
```

**/etc/sysconfig/network-scripts/ifcfg-tap0**

```
DEVICE=tap0
TYPE=Tap
OWNER=vpnuser #use an unprivileged user for your TUN/TAP device
BRIDGE=br0
```

**/etc/sysconfig/network-scripts/ifcfg-eth0**

```
DEVICE="eth0"
ONBOOT="yes"
TYPE=Ethernet
BRIDGE=br0
```

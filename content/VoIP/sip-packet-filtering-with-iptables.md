Title: SIP packets filtering with iptables
Date: 2014-01-22 23:50
Author: admin
Tags: iptables, netfilter, python, sip
Slug: sip-packet-filtering-with-iptables
Status: published

One of the most powerful [iptables](http://www.netfilter.org) match is
the [u32
module](http://www.netfilter.org/documentation/HOWTO/netfilter-extensions-HOWTO-3.html#ss3.21).  
Using the u32 match you are able to write a firewall rule matching
against a single bit of a network packet.

If you wanna play with u32 module you have to be prepared to deal with a syntax very far away from the user friendliness: you have to fight
with commands like the following:

```bash
iptables -I OUTPUT 1 -p udp  \! -f -m u32 --u32 0>>22&0x3C@8=0x494e5649&&0>>22&0x3C@12=0x54452073&&0>>22&0x3C@16=0x69703a33&&0>>22&0x3C@20=0x33383132&&0>>22&0x3C@24=0x33343536&&0>>22&0x3C@28&0xFF000000=0x37000000 -j LOG --log-prefix "--call-to-3381234567 "
```

More over checking contents in variable positions can be very difficult: you need to know the exact data position into the network frame.

Keeping that in mind you can write your rules.

Writing matching rules against SIP methods, SIP URI or response code is
feasible: the IP header comes with a fixed size (this isn't really true,
but you can workaround it) and the UDP header too has a fixed size.

For example this rule logs all the outgoing SIP INVITE to
**sip:3381234567**:  

```
[root@bradbury ~]# iptables -I OUTPUT 1 -p udp  \! -f -m u32 --u32 0>>22&0x3C@8=0x494e5649&&0>>22&0x3C@12=0x54452073&&0>>22&0x3C@16=0x69703a33&&0>>22&0x3C@20=0x33383132&&0>>22&0x3C@24=0x33343536&&0>>22&0x3C@28&0xFF000000=0x37000000
```

Here you can see the network traffic (look at the hex data matching the iptables rule):

```
root@bradbury ~]# tcpdump -nn -i br0 -XX udp and port 5060 and host xxx.xxxxxxxxxx.xx

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode listening on br0, link-type EN10MB (Ethernet), capture size 65535 bytes

22:48:29.362185 IP xxx.xxx.xxx.xxx.5060 > xxx.xxx.xxx.xxx.5060: SIP, length: 965
0x0000:  001f 1249 0acc 5254 00e7 8e30 0800 45a0  ...I..RT...0..E.
0x0010:  03e1 0000 4000 4011 01dd 511d d3c4 d461  ....@.@...Q....a
0x0020:  3b4c 13c4 13c4 03cd 386e 494e 5649 5445  ;L......8nINVITE <--- HERE: look at the 494e 5649 5445 matching the 'INVITE'
0x0030:  2073 6970 3a33 3338 3132 3334 3536 3740  .sip:3381234567@ <--- HERE: look at the SIP URI
0x0040:  7878 782e 7878 7878 7878 7878 7878 2e78  xxx.xxxxxxxxxx.x
0x0050:  783b 7573 6572 3d70 686f 6e65 2053 4950  x;user=phone.SIP
```

Messages are logged (the first one is the INVITE without the
authentication data):


```
[root@bradbury ~]# tail -f /var/log/messages
Jan 22 23:00:28 bradbury kernel: --call-to-3381234567IN= OUT=br0 SRC=xxx.xxx.xxx.xxx DST=xxx.xxx.xxx.xxx LEN=993 TOS=0x00 PREC=0xA0 TTL=64 ID=0 DF PROTO=UDP SPT=5060 DPT=5060 LEN=973
Jan 22 23:00:28 bradbury kernel: --call-to-3381234567IN= OUT=br0 SRC=xxx.xxx.xxx.xxx DST=xxx.xxx.xxx.xxx LEN=1285 TOS=0x00 PREC=0xA0 TTL=64 ID=0 DF PROTO=UDP SPT=5060 DPT=5060 LEN=1265
```

You can write your rules in a more simple way using my

[iptables-SIPu32.py python script](https://github.com/pbertera/scripts/blob/master/iptables-SIPu32.py):

```
iptables -I OUTPUT 1 -p udp  \! -f -m u32 --u32 $(./iptables-SIPu32.py "INVITE sip:3381234567") -j LOG --log-prefix "-j LOG --log-prefix "--call-to-3381234567 "
```

Please note that this script can works with every kind of UDP payload.

**UPDATE:** now the script supports TCP too


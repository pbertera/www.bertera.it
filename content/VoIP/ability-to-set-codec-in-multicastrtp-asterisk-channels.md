Title: Ability to set codec in MulticastRTP Asterisk channels
Date: 2012-12-12 21:08
Author: admin
Tags: asterisk, c, code, patch, rtp, VoIP
Slug: ability-to-set-codec-in-multicastrtp-asterisk-channels
Status: published

[Here]({attach}/static/asterisk_trunk-377802_rtp_multicast_codec.patch)
you can find a port for Asterisk trunk (rev. 377802) of this patch:
<http://lists.digium.com/pipermail/asterisk-dev/2011-September/051262.html>.  
This patch permits to set the codec of an outgoing multicast RTP stream
via the variable MULTICAST_RTP_CODEC:

```
exten => 999,1,Answer()  
exten => 999,n,Set(MULTICAST_RTP_CODEC=alaw)  
exten => 999,n,Dial(MulticastRTP/basic/239.255.255.245:5555,,A(/var/lib/asterisk/moh/mymoh))
```

Title: RTP timestamps fix in Asterisk MulticastRTP channels
Date: 2012-12-12 19:09
Author: admin
Tags: asterisk, c, multicast, patch, rtp, VoIP
Slug: rtp-timestamps-fix-in-asterisk-multicastrtp-channels
Status: published

Starting from Asterisk 1.8 you can [send multicast rtp
streams](http://www.voip-info.org/wiki/view/Asterisk+MulticastRTP+channels)
using the MulticastRTP channel driver. There is an [open
issue](https://issues.asterisk.org/jira/browse/ASTERISK-19883) that
breaks outgoing RTP if the source channel doesn't contains timing
informations (Eg. playing an audio file with
**Dial(MulticastRTP/basic/239.255.255.245:5555,,A(my-announce))**).  
All outgoing RTP frames a timestamp value of 0.

This [patch]({attach}/static/asterisk_trunk-377802-rtp-multicast-timestamp.patch) adds timing information in outgoing RTP stream.

Following an example usage in dialplan:  

```
exten => 999,1,Answer()  
exten => 999,n,Dial(MulticastRTP/basic/239.255.255.245:5555,,A(/var/lib/asterisk/moh/mymoh))
```

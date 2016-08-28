Title: Asterisk and SIP session refresh with UPDATE request
Date: 2012-02-15 07:12
Author: admin
Category: hack
Tags: asterisk, bug, sip, VoIP
Slug: asterisk_and_sip_session_refresh_with_update-request
Status: published

Using **directmedia=update** or (**canreinvite=update** in old-sytle
configuration) in chan_sip.conf Asterisk sends SIP UPDATE request to
refresh SIP session.

If this UPDATE requests refers to an inactive call the phone reply with
**SIP/2.0 481 Call Leg/Transaction Does Not Exist.**

In this situation Asterisk continue in resending UPDATE and doesn't tear
down the previous allocated channel.  
Using INVITE instead UPDATE (**directmedia=yes**) Asterisk correctly
terminate the dialog.

This little chan_sip.c patch (Asterisk 1.8.9.1 version) correct this
behavior:

```
--- asterisk-1.8.9.1/channels/chan_sip.c 2012-02-06 22:40:37.000000000 +0100
+++ /root/asterisk-1.8.9.1/channels/chan_sip.c 2012-02-08 15:30:04.552673312 +0100
@@ -20952,6 +20952,17 @@ static void handle_response(struct sip_p
case 481: /* Call leg does not exist */
if (sipmethod == SIP_INVITE) {
handle_response_invite(p, resp, rest, req, seqno);
+ }
+ else if (sipmethod == SIP_UPDATE) {
+ switch (resp) {
+ case 481: /* Call leg does not exist */
+ ast_log(LOG_WARNING, "Re-invite with UPDATE to non-existing call leg on other UA. SIP dialog '%s'. Giving up.\n", p->callid);
+ //xmitres = transmit_request(p, SIP_ACK, seqno, XMIT_UNRELIABLE, FALSE);
+ if (p->owner)
+ ast_queue_control(p->owner, AST_CONTROL_CONGESTION);
+ sip_scheddestroy(p, DEFAULT_TRANS_TIMEOUT);
+ break;
+ }
} else if (sipmethod == SIP_SUBSCRIBE) {
handle_response_subscribe(p, resp, rest, req, seqno);
} else if (sipmethod == SIP_BYE) {
```

You can download the patch at
<https://github.com/pbertera/junk/blob/master/asterisk-stuff/asterisk-1.8.9.1-UPDATE-reinvite.patch>

Asterisk reported issue: [ASTERISK-19313](https://issues.asterisk.org/jira/browse/ASTERISK-19313)

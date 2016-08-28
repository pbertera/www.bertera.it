Title: Authentication username in Astersik SIP peer
Date: 2010-07-12 09:01
Author: admin
Category: coding, hack
Tags: asterisk, c, patch, VoIP
Slug: authentication-username-in-astersik-sip-peer
Status: published

Asterisk use peername as username during SIP inbound digest
authentication.  
[This
patch](https://github.com/pbertera/junk/blob/master/asterisk-stuff/asterisk-1.6.2.2-sip-peer-authuser-patch.patch)
add **authuser** parameter in SIP peer definition and use authuser in
digest authentication:

**Peer definition in /etc/asterisk/sip.conf**  

```
...
[pietro](sip-client-base)
authuser=MyUsername
secret=XXXXX
qualify=yes
nat=yes
...
```

**Peer definition in my SIP client (Twinkle)**  
![client configuration]({attach}/static/Twinkle-conf.png)

**REGISTER message from my SIP client**  

```
REGISTER sip:bertera.it SIP/2.0
Via: SIP/2.0/UDP 88.149.226.66:10458;rport;branch=z9hG4bKkqpevlic
Max-Forwards: 70
To: "Pietro"
From: "Pietro" ;tag=ntlug
Call-ID: mqezxbywgtulavj@bertuccia
CSeq: 681 REGISTER
Contact: ;expires=3600
Authorization: Digest username="MyUsername",realm="bertera.it",nonce="27f804de",uri="sip:bertera.it",response="47dbf0a57d80faffd148b58d84edc2db",algorithm=MD5 Allow: INVITE,ACK,BYE,CANCEL,OPTIONS,PRACK,REFER,NOTIFY,SUBSCRIBE,INFO,MESSAGE
User-Agent: Twinkle/1.4.2
Content-Length: 0
```

**Message in Asterisk CLI:**  

```
[Feb 4 23:23:35] NOTICE[24864]: chan_sip.c:13016 register_verify: Trying athenticate peer 'pietro' using authuser: 'MyUsername'
-- Registered SIP 'pietro' at 88.149.226.66 port 10458
```

**REGISTER Confirmation from Asterisk:**  

```
SIP/2.0 200 OK
Via: SIP/2.0/UDP 88.149.226.66:10458;branch=z9hG4bKkqpevlic;received=88.149.226.66;rport=10458
From: "Pietro" ;tag=ntlug
To: "Pietro" ;tag=as49faff1f
Call-ID: mqezxbywgtulavj@bertuccia
CSeq: 681 REGISTER
Server: Asterisk PBX 1.6.2.2
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, SUBSCRIBE, NOTIFY, INFO
Supported: replaces, timer
Expires: 3600
Contact: ;expires=3600
Date: Thu, 04 Feb 2010 22:23:35 GMT
Content-Length: 0
```

Here is the chan_sip.c patch against Asterisk 1.6.2.2
```
Index: channels/chan_sip.c
===================================================================
--- channels/chan_sip.c (revision 244766)
+++ channels/chan_sip.c (working copy)
@@ -1825,6 +1825,7 @@
        AST_STRING_FIELD(context);      /*!< Default context for incoming calls */
        AST_STRING_FIELD(subscribecontext); /*!< Default context for subscriptions */
        AST_STRING_FIELD(username);     /*!< Temporary username until registration */ 
+       AST_STRING_FIELD(authuser);     /*!< Username used during inbound authentication */ 
        AST_STRING_FIELD(accountcode);      /*!< Account code */
        AST_STRING_FIELD(tohost);       /*!< If not dynamic, IP address */
        AST_STRING_FIELD(regexten);         /*!< Extension to register (if regcontext is used) */
@@ -13011,7 +13012,9 @@
            ast_copy_flags(&p->flags[0], &peer->flags[0], SIP_NAT);
            if (ast_test_flag(&p->flags[1], SIP_PAGE2_REGISTERTRYING))
                transmit_response(p, "100 Trying", req);
-           if (!(res = check_auth(p, req, peer->name, peer->secret, peer->md5secret, SIP_REGISTER, uri, XMIT_UNRELIABLE, req->ignore))) {
+           if (strcmp(peer->authuser, peer->name))
+               ast_log(LOG_NOTICE, "Trying athenticate peer '%s' using authuser: '%s'\n", peer->name, peer->authuser);
+           if (!(res = check_auth(p, req, peer->authuser, peer->secret, peer->md5secret, SIP_REGISTER, uri, XMIT_UNRELIABLE, req->ignore))) {
                if (sip_cancel_destroy(p))
                    ast_log(LOG_WARNING, "Unable to cancel SIP destruction.  Expect bad things.\n");
 
@@ -14006,7 +14009,7 @@
        ast_string_field_set(p, peersecret, NULL);
        ast_string_field_set(p, peermd5secret, NULL);
    }
-   if (!(res = check_auth(p, req, peer->name, p->peersecret, p->peermd5secret, sipmethod, uri2, reliable, req->ignore))) {
+   if (!(res = check_auth(p, req, peer->authuser, p->peersecret, p->peermd5secret, sipmethod, uri2, reliable, req->ignore))) {
        ast_copy_flags(&p->flags[0], &peer->flags[0], SIP_FLAGS_TO_COPY);
        ast_copy_flags(&p->flags[1], &peer->flags[1], SIP_PAGE2_FLAGS_TO_COPY);
        /* If we have a call limit, set flag */
@@ -15386,6 +15389,7 @@
        }
        ast_cli(fd, "  Secret       : %s\n", ast_strlen_zero(peer->secret)?"<Not set>":"<Set>");
        ast_cli(fd, "  MD5Secret    : %s\n", ast_strlen_zero(peer->md5secret)?"<Not set>":"<Set>");
+       ast_cli(fd, "  Auth User    : %s\n", peer->authuser);
        ast_cli(fd, "  Remote Secret: %s\n", ast_strlen_zero(peer->remotesecret)?"<Not set>":"<Set>");
        for (auth = peer->auth; auth; auth = auth->next) {
            ast_cli(fd, "  Realm-auth   : Realm %-15.15s User %-10.20s ", auth->realm, auth->username);
@@ -23706,8 +23710,10 @@
        set_peer_defaults(peer);    /* Set peer defaults */
        peer->type = 0;
    }
-   if (!found && name)
+   if (!found && name) {
        ast_copy_string(peer->name, name, sizeof(peer->name));
+       ast_string_field_set(peer, authuser, name); /* Set default authuser == peername*/
+   }
```

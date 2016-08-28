Title: Asterisk callback from a failed blind transfer
Date: 2012-10-07 15:34
Author: admin
Category: systems
Tags: asterisk, sip, VoIP
Slug: asterisk-callback-from-a-failed-blind-transfer
Status: published

This little piece of extensions.conf implements a callback from a failed
transfer (attendant and unattendant/bind)

```
exten => _1XX,1,Dial(SIP/${EXTEN},20,tT)
exten => _1XX,n,GotoIf($[ "a${BLINDTRANSFER}" = "a" ]?TransferFailed)
exten => _1XX,n,Set(CALLER=${CUT(BLINDTRANSFER,-,1)});
exten => _1XX,n,Goto(CallBack)
exten => _1XX,n(TransferFailed),GotoIf($[ "a${TRANSFERERNAME}" = "a" ]?Fail)
exten => _1XX,n,Set(CALLER=${CUT(TRANSFERERNAME,-,1)});
exten => _1XX,n(CallBack),Set(CALLERID(all)=${EXTEN} <${CALLERID(num)}>)
exten => _1XX,n,Dial(${CALLER},,tT)
exten => _1XX,n(Fail),Hangup()
```

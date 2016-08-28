Title: What happened to the +39 (Italy) ENUM DNS Zone ? 
Date: 2015-02-25 16:38
Author: admin
Category: Uncategorized
Tags: ENUM, Italy, VoIP
Slug: what-happened-to-the-39-italy-enum-dns-zone
Status: published

[ENUM](https://tools.ietf.org/html/rfc6116) is a DNS based algorithm
used to store data associated with E.164 numbers (aka global phone
numbers). Using ENUM you can associate your email or Skype or SIP
contact along with your phone number.

So, registering your contacts in the ENUM tree you'll make yourself
reachable trough all the ways you published on the ENUM database:
someone needing to contact you will do an ENUM query against your E.164
phone number, the server will answer with all your contacts (email, SIP
URI, Web URL, Instant message, presence service, etc..).

##### ENUM implements a global, multiservice addressbook.

How ENUM works?
===============

1.  As first you need to translate the phone number in the E.164 format
    (for example +39 338 1234567 for the Italian mobile number 338
    1234567)
2.  The E.164 number should reduced to numbers only (393381234567)
3.  All digits should reordered front-back (765432183393)
4.  Insert a dot between each digit (7.6.5.4.3.2.1.8.3.3.9.3)
5.  Add the suffix ".e164.arpa" at the end
    (7.6.5.4.3.2.1.8.3.3.9.3.e164.arpa)
6.  Send a DNS request for the obtained domain and look at the NAPTR
    record

ENUM is globally managed trough a DNS hierarchy:
[RFC6116](https://tools.ietf.org/html/rfc6116#section-6) states:

       Names within this zone are to be delegated to parties consistent with
       ITU Recommendation E.164.  The names allocated should be hierarchic
       in accordance with ITU Recommendation E.164, and the codes should be
       assigned in accordance with that Recommendation.

This means that for example the +49 E.164 country code (Germany) is
managed by the German naming authority:

```
~ pietro$ dig +short NS 9.4.e164.arpa  
enum3.denic.de.  
enum1.denic.de.  
enum2.denic.de.  
```

A working example is the number +43 780 00471:

```
~ pietro$ dig +short 1.1.7.4.0.0.0.8.7.3.4.e164.arpa NAPTR  
100 10 "u" "E2U+web:http" "!\^.\*\$!http://q.nemox.net/!" .  
100 10 "u" "E2U+email:mailto" "!\^.\*\$!mailto:info@nemox.net!" .  
100 10 "u" "E2U+sip" "!\^.\*\$!sip:enum-test@sip.nemox.net!" .  
```

The 9.3.e164.arpa zone
======================

The DNS manging the +39 country code seems not working:

```
~ pietro$ dig +short 9.3.e164.arpa ANY  
;; connection timed out; no servers could be reached  
```

Searching the nameserver managing this zone:

```
~ pietro$ dig +short e164.arpa NS  
sec1.apnic.net.  
tinnie.arin.net.  
pri.authdns.ripe.net.  
sec3.apnic.net.  
ns3.nic.fr.  
sns-pb.isc.org.

~ pietro$ dig @ns3.nic.fr 9.3.e164.arpa NS

; <<>> DiG 9.8.3-P1 <<>> @ns3.nic.fr 9.3.e164.arpa NS  
; (1 server found)  
;; global options: +cmd  
;; Got answer:  
;; ->>HEADER<;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 2,
ADDITIONAL: 0  
;; WARNING: recursion requested but not available

;; QUESTION SECTION:  
;9.3.e164.arpa. IN NS

;; AUTHORITY SECTION:  
9.3.e164.arpa. 172800 IN NS dns2.istsupcti.it.  
9.3.e164.arpa. 172800 IN NS dns.istsupcti.it.  
```

The 9.3.e164.arpa is delegated to dns2.istsupcti.it and
dns.istsupcti.it, no one of them seems working:

```
~ pietro$ dig @dns2.istsupcti.it ANY

; <<>> DiG 9.8.3-P1 <<>> @dns2.istsupcti.it ANY  
; (1 server found)  
;; global options: +cmd  
;; connection timed out; no servers could be reached  
~ pietro$ dig @dns.istsupcti.it ANY

; <<>> DiG 9.8.3-P1 <<>> @dns.istsupcti.it ANY  
; (1 server found)  
;; global options: +cmd  
;; connection timed out; no servers could be reached  
```

##### **Ok, ENUM is totally broken in Italy.**

Let me dig a bit more:

Who is istsupcti.it (seems not have even a working web site)?

```
~ pietro$ whois istsupcti.it

\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*  
\* Please note that the following result could be a subgroup of \*  
\* the data contained in the database. \*  
\* \*  
\* Additional information can be visualized at: \*  
\* http://www.nic.it/cgi-bin/Whois/whois.cgi \*  

\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

Domain: istsupcti.it  
Status: ok  
Created: 1998-12-23 00:00:00  
Last Update: 2015-02-24 00:54:36  
Expire Date: 2016-02-08

Registrant  
Organization: Istituto Superiore delle Comunicazioni e delle Tecnologie
dell'Informazione  
Address: Viale America, 201  
Roma  
00144  
RM  
IT  
Created: 2008-02-08 12:11:24  
Last Update: 2012-07-16 16:14:51

Admin Contact  
Name: Claudia Passaro  
Organization: Istituto Superiore delle Comunicazioni e delle Tecnologie
dell'Informazione  
Address: Viale America, 201  
Roma  
00144  
RM  
IT  
Created: 2012-07-16 14:30:02  
Last Update: 2012-07-16 16:13:49

Technical Contacts  
Name: Gestione Domini  
Address: Via Caracciolo, 51  
MILANO  
20155  
MI  
IT  
Created: 2005-07-07 00:00:00  
Last Update: 2014-06-20 14:07:55

Registrar  
Organization: Fastweb s.p.a.  
Name: FASTWEB-REG

Nameservers  
dns1.fweds-spc.it  
dns2.fweds-spc.it  
```

[Googling](http://lmgtfy.com/?q=Istituto+Superiore+delle+Comunicazioni+e+delle+Tecnologie+dell%27Informazione)
for "Istituto Superiore delle Comunicazioni e delle Tecnologie
dell'Informazione" I found the [website](http://www.isticom.it/).

10 years of testing
===================

Searching on the RIPE archive I found the [delegation
request](https://www.ripe.net/ripe/mail/archives/enum-announce/2005-October/000046.html)
for the +39 ENUM prefix: it was in October 2005: Almost ten years ago!
The request comes from the Voipex consortium (from the
[website](http://www.voipex.it/) it looks more or less died now).

Digging on the Internet you can find
[some](http://www.voipblog.it/enum-e-regolamentazione-voip-281.html) old
[posts](http://punto-informatico.it/1440878/Telefonia/News/enum-piu-vicina-vera-telefonia-ip.aspx)
saying that we entered in a test phase for the ENUM introduction.

Searching on the AGCOM (The Italian Communications Authority) website
you can see some [documents](http://www.agcom.it/risultati?q=enum)
mentioning ENUM as a maybe/future technology to adopt.

The result at the moment is that after 10 years of testing, a consortium
foundation, various ISP involved, ENUM isn't working at all and we
cannot find test results, adoptions guidelines nor regulation rules.

##### Just for the taxpayers happiness!

I just sent an email to urp.comunicazioni@mise.gov.it
("Istituto Superiore delle Comunicazioni e delle Tecnologie
dell'Informazione" [PR
office](http://www.isticom.it/index.php/contatti) ), I tried to send an
email to AGCOM too but I crashed against this message:

![agcom]({attach}/static/agcom-300x170.png)]

If you have any information about ENUM in Italy, feel free to
[contact](http://www.bertera.it/index.php/contacts/) me.

##### to be continued ...

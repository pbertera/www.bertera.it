Title: Changes on the Italian "Golden Tree"
Date: 2015-03-02 21:03
Author: admin
Category: Uncategorized
Tags: dns, ENUM, VoIP
Slug: changes-on-the-italian-golden-tree
Status: published

This is a continuation of my [previous
post](http://www.bertera.it/index.php/2015/02/25/what-happened-to-the-39-italy-enum-dns-zone/ "What happened to the +39 (Italy) ENUM DNS Zone ?")
about the **+39 ENUM DNS zone**.

Thanks to the powerful of the RIPE Database you can see all historical
changes on a RIPE-assigned domain. Lets see what happen on the
domain **9.3.e164.arpa**.

List all changes on the domain object:

``` 
~ pietro$ whois -h whois.ripe.net -- "--list-versions 9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Version history for DOMAIN object "9.3.e164.arpa"  
% You can use "--show-version rev\#" to get an exact version of the
object.

rev\# Date Op.

1 2005-11-02 15:21 ADD/UPD  
2 2006-02-10 11:41 ADD/UPD  
3 2006-04-07 17:56 ADD/UPD  
4 2006-04-07 18:00 ADD/UPD

% This query was served by the RIPE Database Query Service version 1.78 (DB-4)  
``` 

So, the domain was changed 4 times:

-   **Version N°1:** 2005-11-02
-   **Version N°2:** 2006-02-10
-   **Version N°3 and 4:** 2006-04-07

The object in the first version:

``` 
~ pietro$ whois -h whois.ripe.net -- "--show-version 1 9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Version 1 of object "9.3.e164.arpa"  
% This version was a UPDATE operation on 2005-11-02 15:21  
% You can use "--list-versions" to get a list of versions for an
object.

domain: 9.3.e164.arpa  
descr: Italy ENUM Mapping  
descr: Italy ENUM Registry  
admin-c: LF1894-RIPE  
tech-c: GT2177-RIPE  
zone-c: GT2177-RIPE  
nserver: dns.voipex.it  
nserver: dns2.voipex.it  
remarks: Ministero delle Comunicazioni - http://www.comunicazioni.it  
remarks: Istituto Superiore delle Comunicazioni  
remarks: e delle tecnologie dell'Informazione -  
remarks: http://www.iscom.gov.it  
remarks: Consorzio VOIPEX - http://www.voipex.it  
mnt-by: MNT-VOIPEX  
source: RIPE \# Filtered

% This query was served by the RIPE Database Query Service version 1.78 (DB-2)  
``` 

Ok, the first version was the assignment to the Voipex consortium,
[see](https://www.ripe.net/ripe/mail/archives/enum-announce/2005-October/000046.html)
the request.

Here the second version of the object (updated at 2006-02-10 11:41):

``` 
~ pietro$ whois -h whois.ripe.net -- "--show-version 2 9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Version 2 of object "9.3.e164.arpa"  
% This version was a UPDATE operation on 2006-02-10 11:41  
% You can use "--list-versions" to get a list of versions for an
object.

domain: 9.3.e164.arpa  
descr: Italy ENUM Mapping  
descr: Italy ENUM Registry  
admin-c: LF1894-RIPE  
tech-c: LF1894-RIPE  
zone-c: LF1894-RIPE  
nserver: dns.voipex.it  
nserver: dns2.voipex.it  
remarks: Ministero delle Comunicazioni - http://www.comunicazioni.it  
remarks: Istituto Superiore delle Comunicazioni e delle tecnologie
dell'Informazione  
remarks: http://www.iscom.gov.it  
mnt-by: ISCOM-MNT  
source: RIPE \# Filtered

% This query was served by the RIPE Database Query Service version 1.78 (DB-3)  
``` 

In this second version the domain is now delegated to ISCOM (Istituto
Superiore delle Comunicazioni e delle tecnologie dell'Informazione).
Nameservers were still on Voipex.

Below the differences between version 2 and version 3: Namserver moved
from Voipex to istsupcti.it

``` 
~ pietro$ whois -h whois.ripe.net -- "--diff-versions 2:3
9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Difference between version 2 and 3 of object "9.3.e164.arpa"

@@ -6,4 +6,4 @@  
zone-c: LF1894-RIPE  
-nserver: dns.voipex.it  
-nserver: dns2.voipex.it  
+nserver: dns.istsupcti.it  
+nserver: dns2.istsupcti.it  
remarks: Ministero delle Comunicazioni - http://www.comunicazioni.it

% This query was served by the RIPE Database Query Service version 1.78 (DB-2)  
``` 

There isn't differences between revisions 3 and 4:

``` 
~ pietro$ whois -h whois.ripe.net -- "--diff-versions 3:4
9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Difference between version 3 and 4 of object "9.3.e164.arpa"

% This query was served by the RIPE Database Query Service version 1.78 (DB-2)  
``` 

The Vatican long hand
---------------------

WTF? Vatican ? Yes this is quite interesting: seems that someone at
Vatican city has something to do with the Italian golden tree:

``` 
~ pietro$ whois -h whois.ripe.net -- "-B 9.3.e164.arpa"  
% This is the RIPE Database query service.  
% The objects are in RPSL format.  
%  
% The RIPE Database is subject to Terms and Conditions.  
% See http://www.ripe.net/db/support/db-terms-conditions.pdf

% Information related to '9.3.e164.arpa'

domain: 9.3.e164.arpa  
descr: Italy ENUM Mapping  
descr: Italy ENUM Registry  
admin-c: LF1894-RIPE  
tech-c: LF1894-RIPE  
zone-c: LF1894-RIPE  
nserver: dns.istsupcti.it  
nserver: dns2.istsupcti.it  
remarks: Ministero delle Comunicazioni - http://www.comunicazioni.it  
remarks: Istituto Superiore delle Comunicazioni e delle tecnologie
dell'Informazione  
remarks: http://www.iscom.gov.it  
notify: pasquini@vatican.va  
mnt-by: ISCOM-MNT  
changed: pasquini@vatican.va 20060407  
source: RIPE

person: Luisa Franchina  
address: Viale America 201  
address: I-00144 Roma  
address: Italy  
phone: +39 06 54444267  
fax-no: +39 06 54444222  
e-mail: luisa.franchina@comunicazioni.it  
nic-hdl: LF1894-RIPE  
remarks: Ministero delle Comunicazioni  
remarks: Direttore Generale Istituto Superiore Comunicazioni  
notify: pasquini@vatican.va  
mnt-by: ISCOM-MNT  
changed: pasquini@vatican.va 20051031  
source: RIPE

% This query was served by the RIPE Database Query Service version 1.78 (DB-1)  
``` 

Ok, maybe the reason can be that Vatican City actually shares the
Italian country code (+39) despite the fact that ITU-T allocated a
dedicated Vatican City one (+379).

Just for the records: I sent an email to Pasquini@Vatican and Franchina
of  Communication Ministry.

**At the moment of writing still no answers on my previous email...**

[EDIT:] Today (6 March 2015) I received the permanent delivery failure
from my SMTP: comunicazioni.it doesn't has a working email system and my
email to the responsible person for the 9.3.e164.arpa cannot be
delivered. Still no answers on my other email.

##### ... To be continued ...

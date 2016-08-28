Title: Client side result pagination in python-ldap
Date: 2011-10-25 13:28
Author: admin
Category: hack, scripts
Tags: code, ldap, python, python-ldap
Slug: client-side-result-pagination-in-python-ldap
Status: published

Sometime I must fighting with monkeys-configured LDAP servers.  
This time DIT does not support
[RFC2696](http://www.ietf.org/rfc/rfc2696 "RFC2696") (Paged Results for
LDAP query), the data tree contains over 90000 entries.  
Thanks to ldap.resiter is possible to implement client side pagination
in ldap scripts.  
These simple lines of code explain how to:

```
import ldap
import pprint
import ldap.resiter
import sys
 
ldap_uri = "ldap://my.ldap.server"
ldap_base = "dc=example,dc=com"
page_entry_num = 5
 
class MyLDAPObject(ldap.ldapobject.LDAPObject,ldap.resiter.ResultProcessor):
    pass
 
ldapconn = MyLDAPObject(ldap_uri)
msg_id = ldapconn.search(ldap_base, ldap.SCOPE_SUBTREE, "(objectclass=*)")
 
i = 0
for res_type,result,res_msgid,res_controls in ldapconn.allresults(msg_id):
    if i &gt;= page_entry_num:
        try:
            raw_input('Press Enter for nex page or CTRL-C to interrupt:')
        except KeyboardInterrupt:
            ldapconn.abandon(msg_id)
            print "..Bye."
            sys.exit()
 
        i = 0
 
    for rdn, ldap_obj in result:
        print "***********************"
        print "RDN: " + rdn
        print "***********************"
        pprint.pprint(ldap_obj)
        print "***********************"
        print ""
 
    i = i + 1
```

Title: Encoding and decoding Encapsulated DHCP options (RFC 2132)
Date: 2012-10-19 10:38
Author: admin
Category: scripts, systems
Tags: decoding, dhcp, encapsulated options, encoding, python, rfc2132
Slug: encoding-and-decoding-encapsulated-dhcp-options-rfc-2132
Status: published

Vendor specific DHCP options may be provided encapsulated in DHCP option
43.  
With [this little script](https://github.com/pbertera/junk/tree/master/dhcp-encapsulated-options) you
can encode and decode vendor encapsulated option according to [RFC
2132](http://www.ietf.org/rfc/rfc2132.txt).

For example with this command you can tunnel options 66 (TFTP Server),
67 (TFTP Path), 132 (VLAN ID) and 133 (VLAN QOS):

```
$ ./dhcp-encapsulated-options.py encode 66 http://provisionig.example.com 67 settings.xml 132 33 133 6
Encoding part 1: http://provisionig.example.com
 Option ID: 66
 Option length: 30
 Encoded Option part: 42:1E:68:74:74:70:3A:2F:2F:70:72:6F:76:69:73:69:6F:6E:69:67:2E:65:78:61:6D:70:6C:65:2E:63:6F:6D
 
Encoding part 2: settings.xml
 Option ID: 67
 Option length: 12
 Encoded Option part: 43:0C:73:65:74:74:69:6E:67:73:2E:78:6D:6C
 
Encoding part 3: 33
 Option ID: 132
 Option length: 2
 Encoded Option part: 84:02:33:33
 
Encoding part 4: 6
 Option ID: 133
 Option length: 1
 Encoded Option part: 85:01:36
 
Full encoded options: 42:1E:68:74:74:70:3A:2F:2F:70:72:6F:76:69:73:69:6F:6E:69:67:2E:65:78:61:6D:70:6C:65:2E:63:6F:6D:43:0C:73:65:74:74:69:6E:67:73:2E:78:6D:6C:84:02:33:33:85:01:36
```

And then you can add the encoded options in you dhcpd config file:

```
host device.labo.local {  
    hardware ethernet 01:04:23:3b:d0:21;  
    fixed-address 172.16.18.30;  
    option vendor-encapsulated-options
    42:1E:68:74:74:70:3A:2F:2F:70:72:6F:76:69:73:69:6F:6E:69:67:2E:65:78:61:6D:70:6C:65:2E:63:6F:6D:43:0C:73:65:74:74:69:6E:67:73:2E:78:6D:6C:84:02:33:33:85:01:36;  
}
```

And viceversa you can decode an encapsulated option:


```
$ ./dhcp-encapsulated-options.py decode 42:1E:68:74:74:70:3A:2F:2F:70:72:6F:76:69:73:69:6F:6E:69:67:2E:65:78:61:6D:70:6C:65:2E:63:6F:6D:43:0C:73:65:74:74:69:6E:67:73:2E:78:6D:6C
Decoding part 1: 42:1E:68:74:74:70:3A:2F:2F:70:72:6F:76:69:73:69:6F:6E:69:67:2E:65:78:61:6D:70:6C:65:2E:63:6F:6D
 Option ID: 66
 Option lenght: 30
 Option value: "http://provisionig.example.com"
 
Decoding part 2: 43:0C:73:65:74:74:69:6E:67:73:2E:78:6D:6C
 Option ID: 67
 Option lenght: 12
 Option value: "settings.xml"
 
End of encoded options
```

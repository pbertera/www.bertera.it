Title: A DNS server with Batteries Included with PowerDNS, Docker and Python
Date: 2016-09-06 03:25
Author: Pietro
Tags: Docker, Python, REST, PowerDNS


If you have to frequently create, destroy and re-configure DNS zones for testing purposes you will agree that manually editing a Bind [zone file](http://www.zytrax.com/books/dns/ch6/mydomain.html) is an annoying and error-prone task.

In order to make this job simpler I worked on [this](https://hub.docker.com/r/pbertera/pdns/) Docker container: the container instantiate a [PowerDNS](https://www.powerdns.com/) and provides an easy-to-use [CLI script](https://github.com/pbertera/PowerDNS-CLI) interacting with the REST API.

## How to use:

Inspired by the illuminating [@jessfraz](https://twitter.com/jessfraz) [post](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/) about containerizing everything, I added to my [.dockerfunc](https://github.com/pbertera/dotfiles/blob/master/.dockerfunc) some helper functions: 

```bash
pdns() {
    local name=pdns
    if is_running $name; then
        bailout "Container $name is already running"
        return
    fi

    del_stopped $name

    docker run -it --name $name -e API_KEY=MySecretKey -e WEB_PORT=8081 -v ${PDNS_DB}:/data/pdns.db -p 8081:8081 -p 53:53 -p 53:53/udp pbertera/${name}
}

pdns.py(){
    relies_on pdns
    docker exec -it pdns pdns.py "$@"
}
```

*NOTE:* for the first run you will need to create an empty database file: `touch ${PDNS_DB}`

Then I can start the container:

```
hank-2:~ pietro$ pdns
pdns
Error: near line 3: table domains already exists
Error: near line 13: index name_index already exists
Error: near line 16: table records already exists
Error: near line 31: index rec_name_index already exists
Error: near line 32: index nametype_index already exists
Error: near line 33: index domain_id already exists
Error: near line 34: index orderindex already exists
Error: near line 37: table supermasters already exists
Error: near line 43: index ip_nameserver_pk already exists
Error: near line 46: table comments already exists
Error: near line 57: index comments_domain_id_index already exists
Error: near line 58: index comments_nametype_index already exists
Error: near line 59: index comments_order_idx already exists
Error: near line 62: table domainmetadata already exists
Error: near line 70: index domainmetaidindex already exists
Error: near line 73: table cryptokeys already exists
Error: near line 82: index domainidindex already exists
Error: near line 85: table tsigkeys already exists
Error: near line 92: index namealgoindex already exists
Imported schema structure
Sep 06 01:24:36 Reading random entropy from '/dev/urandom'
Sep 06 01:24:36 Loading '/usr/lib/x86_64-linux-gnu/pdns/libgsqlite3backend.so'
Sep 06 01:24:36 This is a standalone pdns
Sep 06 01:24:36 Listening on controlsocket in '/var/run/pdns.controlsocket'
Sep 06 01:24:36 UDP server bound to 0.0.0.0:53
Sep 06 01:24:36 Unable to enable timestamp reporting for socket
Sep 06 01:24:36 UDPv6 server bound to [::]:53
Sep 06 01:24:36 TCP server bound to 0.0.0.0:53
Sep 06 01:24:36 TCPv6 server bound to [::]:53
Sep 06 01:24:36 PowerDNS Authoritative Server 4.0.0-alpha2 (C) 2001-2016 PowerDNS.COM BV
Sep 06 01:24:36 Using 64-bits mode. Built using gcc 5.3.1 20160330.
Sep 06 01:24:36 PowerDNS comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it according to the terms of the GPL version 2.
Sep 06 01:24:36 Listening for HTTP requests on 0.0.0.0:8081
Sep 06 01:24:36 Creating backend connection for TCP
Sep 06 01:24:36 About to create 3 backend threads for UDP
Sep 06 01:24:36 Done launching threads, ready to distribute questions
```

Now PowerDNS is running and listening on the port `8081` for the REST API and the port `53` UDP and TCP for the DNS queries, the database is permanently stored into the SQLite DB file `${PDNS_DB}`.

Using the command `pdns.py` you can manage the zones:

### Creating a zone:

```
hank-2:~ pietro$ pdns.py --zone example.com. --zoneType MASTER --nameserver ns.example.com.  add_zone
2016-09-06 01:57:09,938 pdns         INFO     DNS Zone 'example.com.' Successfully Added...
hank-2:~ pietro$ pdns.py --zone example.com. --recordType A --name ns.example.com. --content 172.16.18.15 add_record
2016-09-06 01:58:04,316 pdns         INFO     DNS Record 'ns.example.com.' Successfully Added/Updated
```

#### Digging the zone:

```
hank-2:~ pietro$ dig @localhost example.com NS

; <<>> DiG 9.8.3-P1 <<>> @localhost example.com NS
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57709
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;example.com.           IN  NS

;; ANSWER SECTION:
example.com.        3600    IN  NS  ns.example.com.

;; Query time: 16 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Tue Sep  6 03:59:18 2016
;; MSG SIZE  rcvd: 46

hank-2:~ pietro$ dig @localhost ns.example.com 

; <<>> DiG 9.8.3-P1 <<>> @localhost ns.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49682
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;ns.example.com.            IN  A

;; ANSWER SECTION:
ns.example.com.     3600    IN  A   172.16.18.15

;; Query time: 13 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Tue Sep  6 03:59:58 2016
;; MSG SIZE  rcvd: 48
```

## Credits

All the credits to [Larry Smith Jr.](http://everythingshouldbevirtual.com/) for the original pdns.py script and [Renan Gonçalves](https://github.com/renan) for the original [PowerDNS+MySQL](https://github.com/renan/powerdns-docker) Docker container

Title: cisco IOS: Monitorare una vpn
Date: 2011-08-23 20:54
Author: admin
Category: hack, systems
Tags: cisco, ios, monitoring, vpn
Slug: cisco-ios-monitorare-una-vpn
Status: published

Avere a che fare con delle connettività scadenti è sempre un disastro.

Uno strumento per tenere monitorata una VPN e reagire in caso di down
puo' essere comodo.

**Esempio:**  
In questo esempio ho una VPN tra la rete A (192.168.2.0/24) e la rete B
(192.168.8.0/24)  
L'endpoint della rete A (192.186.2.1) è un router Cisco, l'enpoint B
(192.168.8.1) non è in nostra gestione ma parla IPSec. Tramite le
configurazione seguenti l'endpoint A tiene monitorato lo stato della VPN
e in caso di down effettua il reload della VPN.

1\) definiamo lo **sla monitor** in modo che esegua un ping verso l'host
192.168.8.1. Dobbiamo definire il source address in modo da essere
sicuri di utilizzare il tunnel cifrato e lo scheduling in modo da
eseguire il test sempre. E' possibile impostare una frequenza di
esecuzione, di default è 60 secondi.

     ip sla monitor 5
     type echo protocol ipIcmpEcho 192.168.8.1 source-ipaddr 192.168.2.1
     exit
     ip sla monitor schedule 1 life forever start-time now 

2\) definiamo un tracker per lo sla monitor creato precedentemente:
vogliamo monitorare quando lo **sla monitor 5** ritorna route
unreachable e reagire solo se lo stato di down permane per piu' di 60
secondi.

     track 1 rtr 5 reachability
     delay down 60 

3\) definiamo il "reattore"  
Le configurazioni immesse finora fanno in modo che se l'host
192.168.8.1 rimane irraggiungibile per piu' di 60 secondi viene generato
un evento nel syslog locale. L'event manager applet seguente si occupa
di intercettare l'evento syslog, eseguire il reload della VPN e loggare
il messaggio "VPN Reloaded"

     event manager applet VPN-IS-DOWN
     event syslog pattern "TRACKING-5-STATE: 5 .*Up->Down"
     action 1.0 cli command "enable"
     action 2.0 cli command "clear crypto session remote b.public.ip"
     action 3.0 cli command "end"
     action 4.0 syslog msg "VPN Reloaded"

[Cisco IOS IP SLA configuration
guide](http://www.cisco.com/en/US/docs/ios/12_4/ip_sla/configuration/guide/hsla_c.html)  
[Cisco IOS IP SLAs command
reference](http://www.cisco.com/en/US/docs/ios/ipsla/command/reference/sla_book.html)  
[Writing Cisco embedded event manager
policy](http://www.cisco.com/en/US/docs/ios/netmgmt/configuration/guide/nm_eem_policy_cli.html)


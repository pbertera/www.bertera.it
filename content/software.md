Title: Software
Date: 2006-02-05 16:22
Author: admin
Category: hack
Tags: bacula, nagios, python, rsync, script
Slug: software
Status: published

Era un progettino che avevo dato all’università : esegue dei backup
differenziali o full utilizzando rsync:
[Batbu](https://github.com/pbertera/junk/tree/master/batbu)

Bacula: i .deb per sarge della 1.38.5
[bacula-1.38.5](http://www.bertera.it/software/bacula-1.38.5/) **UPDATE:** non piu' mantenuto

Plugin nagios:

* **check-imap-login** Un plugin per nagios per eseguire un login su un server IMAP (o IMAPS)
[chek-imap-login](https://github.com/pbertera/junk/blob/master/nagios-stuff/check_imap_login)
* **chek-load-login** Altro plugin per verificare il carico di una macchina via ssh con due
soglie di allarme [check_load_ssh](https://github.com/pbertera/junk/blob/master/nagios-stuff/check_load_ssh)
* **check-horde-login** Plugin che fa il logon in horde web mail

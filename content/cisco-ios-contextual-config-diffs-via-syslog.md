Title: cisco IOS contextual config diffs via syslog
Date: 2010-10-11 11:11
Author: admin
Category: hack
Tags: cisco, cli, syslog
Slug: cisco-ios-contextual-config-diffs-via-syslog
Status: published

Event amanager applet per salvare il diff tra stratup-config e
running-config via syslog.

```
event manager applet wr-mem-match 
 event cli pattern "wr.* mem.*" sync yes
 action 1.0 cli command "enable"
 action 1.1 cli command "show archive config differences nvram:/startup-config system:/running-config"
 action 1.2 syslog msg "$_cli_result"
 set 2.0 _exit_status 1
```

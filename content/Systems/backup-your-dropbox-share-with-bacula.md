Title: Backup your Dropbox share with bacula
Date: 2012-07-27 22:33
Author: admin
Tags: backup, bacula, bash, dropbox
Slug: backup-your-dropbox-share-with-bacula
Status: published

I don't
[like](http://www.zdnet.com/blog/bott/sorry-dropbox-i-still-dont-trust-you/4173)
cloud storage, especially I don't like Dropbox security
[history](http://www.schneier.com/blog/archives/2011/05/dropbox_securit.html).  
Anyway Dropbox and others cloud storage are damn cheap and easy to use,
I use it for sharing non-important documents.

This little howto explain how you can backup your Dropbox share with
[Bacula](http://www.bacula.org).

First you must install Dropbox in your server:

* Download the python **CLI script** from [here](https://www.dropbox.com/install?os=lnx): `wget https://linux.dropbox.com/packages/dropbox.py`
* and install: `LC_ALL=C python26 ./dropbox.py start -i`
* run it: `LC_ALL=C python26 ./dropbox.py start`
* Now Dropbox start reply with a link:

```
To link this computer to a dropbox account, visit the following url:  

https://www.dropbox.com/cli_link?host_id=4258saj1921sa123aa17329a12e3&cl=en_US  
```

* Copy and paste the in your browser and insert you DropBox credentials, after you can restart Dropbox.  
Dropbox will sync your storage with your ~/Dropbox folder. You can check the status with the command: `LC_ALL=C python26 ./dropbox.py status`
*When your Dropbox folder is fully syncronized you can stop Dropbox `LC_ALL=C python26 ./dropbox.py stop`


This little script starts local dropbox sync process and check the
status, the script exit with success if your Dropbox folder is in-sync,
and with an error code you a timeout event is reached (configure maxwait
and recheck variabales). You can use this script as Pre-client-script in
your bacula job.

```
#!/bin/bash
 
maxwait=20 #number of maximum re-check
recheck=2 #seconds between recheck
dropbox="python26 /root/dropbox.py"
 
 
do_ok(){
        $dropbox stop
        exit 0
}
 
cd ~
# start DR
export LC_ALL=C
$dropbox start
 
 
x=0
while [ $x -le $maxwait ]
do
        sleep $recheck
        status=$($dropbox filestatus Dropbox | cut -d \  -f2-)
        [ "$status" == "up to date" ] && do_ok
        x=$(( $x + 1 ))
        echo "Dropbox not updated.. ($x)"
done
echo "Timeout reached."
$dropbox stop
exit 255
```

Following the bacula configuration for this job: Job definition and
FilSet:

```
FileSet {
  Name = "DropBox Full Set"
  Include {
    Options {
      signature = MD5
    }
    File = /root/Dropbox
  }
}
 
Job {
  Name = "BackupDropBox"
  Client = stoker-fd
  FileSet = "DropBox Full Set"
  JobDefs = "DefaultJob"
  RunScript {
    RunsWhen = Before
    FailJobOnError = Yes
    Command = "/etc/bacula/scripts/sync-dropbox.sh"
  }
}
```

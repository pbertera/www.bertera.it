Title: SQL Server backup con Bacula
Date: 2008-05-30 17:06
Author: admin
Category: hack
Tags: bacula, sql server, windows
Slug: sql-server-backup-con-bacula
Status: published

In teoria con una versione recente di Bacula ed il supporto VSS si
dovrebbe poter eseguire il backup in maniera consistente prelevando
direttamente i file dei database.  
Per chi non si fida
[questa](https://github.com/pbertera/junk/blob/master/mssql-backup/dump.sql) stored
procedure esegue il dump di tutti i database utente in file .BAK.

Viene installata ed eseguita tramite
[questo](https://github.com/pbertera/junk/blob/master/mssql-backup/pre-backup.bat)
.bat richiamato da un “ClientRunBeforeJob”. (Ovvio che la directory che
contiene i .BAK deve essere compresa nel FIleSet del client).

Lo script [post-bakup](https://github.com/pbertera/junk/blob/master/mssql-backup/post-backup.bat)
si occupa di ripulire la directory di appoggio dai dump.

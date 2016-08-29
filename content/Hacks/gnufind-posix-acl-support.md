Title: GNU/Find posix acl support
Date: 2009-09-28 18:25
Author: admin
Tags: c, find, gnu
Slug: gnufind-posix-acl-support
Status: published

Cercare file che corrispondono a delle acl posix all'interno di un
filesystem molto intricato è sempre un delirio.

[Questa](https://github.com/pbertera/junk/tree/master/findutils-acl) patch aggiunge
l'opzione -acl al comando find
([GNU/Findutils](http://www.gnu.org/software/findutils/)).

Esempio d'uso:

```
$ touch 1 2 3 4
$ mkdir 5
$ setfacl -m u:root:rx 1
$ setfacl -m g:bin:rw 2
$ setfacl -m u:pietro:--- 3
$ setfacl -m g:bin:rw 3
$ setfacl -m g:wheel:r 4
$ setfacl -m d:u:root:rwx 5
$ touch 5/6
$ setfacl -m g:wheel:r 5/6

$ find . -acl u:root:rx
./1
$ find . -acl u:root:*
./1
./5/6
$ find . -acl u:*:rx
./1
$ find . -acl g:*:*
./4
./3
./5/6
./2
$ find . -acl d:u:*:*
./5
```

Questa patch e' stata testata solo su Linux, è scaricabile qua:
<https://github.com/pbertera/junk/tree/master/findutils-acl> è disponibile per la
versione 4.42 e 4.5.6 di findutils


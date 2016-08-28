Title: Reading Windows and Office product key
Date: 2008-12-17 15:04
Author: admin
Category: coding
Tags: product key, python, registry, windows
Slug: reading-windows-and-office-product-key
Status: published

I product key di M\$ Windows e Office vengono salvati nel registro in
alcune chiavi cifrate  
Pygetkey decifra le chiavi e le stampa a video oppure le salva in
chiaro in un'altra chiave di registro. Puo' inoltre preleveare i product
key da un pc remoto.

Pygetkey è scritto in python e richiede un'installazione di python 2.X
per windows

Esempio:  `pygetkey -c SYSTEMTest` creerà i valori WINDOWS-KEY e OFFICE-2007-KEY all'interno della chiave
HKEY\_LOCAL\_MACHINESYSTEMTest:  

```
[HKEY_LOCAL_MACHINESYSTEMTest] "WINDOWS-KEY"="XQM13-K3M7R-32HRX-XF3Q-GMF63" "OFFICE-2007-KEY"="JPBW9-BPY6B-79M9M-RJYJV-6G5B6"
```

i valori vengono creati sotto l'albero di registro HKEY_LOCAL_MACHINE
nella chiave specificata dal parametro -c e potranno avere i seguenti nomi:

* WINDOWS-KEY: la chiave di windows  
* OFFICE-{2000,2007,2003,XP}-KEY: le chiavi di office trovate a seconda della versione
  
La chiave specificata dal comando DEVE esistere, in caso contrario
verrà ritornato un errore.

L'opzione -r HOST indica a pygetkey di interrogare un host remoto.

**Leggere chiavi di registro su un pc remoto:**  
readrreg.py è ingrado di leggere le chiavi di registro da un pc remoto:

```
C:devgetkey>readrreg.py -k "SYSTEMTest" -r RemotePC office-2007-key: XQM13-K3M7R-32HRX-XF3Q-GMF63 windows-key: JPBW9-BPY6B-79M9M-RJYJV-6G5B6
```

**Creazione dei binari**  
E' possibile creare un eseguibile di pygetkey e readrreg in modo da non
installare python sui pc, per creare i binari occorre  
installare py2exe (http://www.py2exe.org) per l'appropriata versione di

Python ed eseguire il seguente comando: `python.exe setup.py py2exe`

Qesto creera' una directory dist contente dei file, quelli strettamente
necessari all'esecuzione di pygetkey.exe e readrreg.exe sono:

* pygetkey.exe  
* readrreg.exe  
* library.zip  
* python25.dll (il 25 dipende dalla versione di Python installata)  
* MSVCR71.dll

PS: non sono sicuro funzioni correttamente con Office 2000

**Download:**  

pygetkey è scaricabile [qua](https://github.com/pbertera/junk/tree/master/pygetkey)

 
python è scaricabile all'indirizzo: <http://www.python.org>  
py2exe è scaricabile all'indirizzo: <http://www.py2exe.org>

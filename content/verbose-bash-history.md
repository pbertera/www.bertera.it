Title: Verbose bash history
Date: 2009-07-02 08:58
Author: admin
Category: hack
Slug: verbose-bash-history
Status: published

Usando questo codice durante l'inizializzasione della shell viene
salvata una command history nel file *.bash\_verbose\_history* contenete
data e ora, tty (oppure l'ip se l'utente è collegato in ssh) eil comando
eseguito. Inoltre evita la sovrascrittura del file
*.bash_verbose_history* e *.bash_history* eseguendone una copia
quando il file raggiunge le 3000 righe.

**/etc/bashrc**

```
HISTSIZE=4000
HISTFILESIZE=4000

for f in .bash_history .bash_verbose_history; do
        if [ `wc -l $HOME/$f | awk '{print $1}'` -gt 3000 ] ; then
                cp -f $HOME/$f $HOME/$f-`date -I`
        fi
done

if [ -n "$SSH_CLIENT" ]; then
        TTY=`echo $SSH_CLIENT| cut -d   -f1`
else
        TTY=`tty | sed -e "s:/dev/::"`
fi

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo `date +"%Y-%m-%d %k:%M:%S"` $USER $TTY "$(history 1)" >> ~/.bash_verbose_history'
```

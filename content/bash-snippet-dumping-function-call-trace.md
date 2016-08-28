Title: bash snippet: dumping function call trace
Date: 2011-07-18 12:44
Author: admin
Category: scripts
Tags: bash, debugging, script
Slug: bash-snippet-dumping-function-call-trace
Status: published

Uno snippet di codice bash utile nel debugging di script.

```
#@.. function:: __cm_exit_error([text],[...])
#@
#@   Stampa la stringa passata in stderr ed esce
#@   Se è impostata la variabile __cm_debug stampa lo stack di chiamata delle funzioni
#@
#@   :param text: la stringa da stampare
#@   :type text: String
#@
__cm_exit_error()

{
        echo "Error in ${FUNCNAME[1]}:${BASH_LINENO[0]}: $*" 1>&2
        local i=0
        [ $__cm_debug ] && while [ $i -lt ${#FUNCNAME} ]; do
                [ "${FUNCNAME[$i]}" == "main" ] && break
                echo "${BASH_SOURCE[$i]}::${FUNCNAME[$i + 1]}::${BASH_LINENO[$i]}" 1>&2
                i=$(expr $i + 1)
        done
        exit 1
}
```

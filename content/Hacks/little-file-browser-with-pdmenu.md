Title: Little file browser with pdmenu
Date: 2012-03-10 02:15
Author: admin
Tags: coding, pdmenu, perl
Slug: little-file-browser-with-pdmenu
Status: published

[Pdmenu](http://kitenet.net/programs/pdmenu/) is a menu system for Unix.
It is designed to be easy to use, and is suitable for a login shell for
inexperienced users, or it can just be run at the command line as a
handy menu program.

I just modified showdir.pl script in order to implement a small and
minimal file browser for using pdmenu.

You can add/delete file and directory and edit files. Some screenshot
below:

![run menu]({attach}/static/pdmenu1.png)

![menu]({attach}/static/pdmenu2.png)

this is the [pdmenu configuration file](https://github.com/pbertera/junk/blob/master/showdir/menutest):

```
#! /usr/bin/pdmenu -c
#
## Version 2.0
#
## Title
preproc: echo "Title: test"
color:desktop:blue:blue
color:title:red:white
color:base:blue:white
# File manager
menu:provisioning: Provisioning file management : 
group:_Edit a file
    exec::makemenu: (\
            /usr/share/pdmenu/editdir.pl /var/www "" show_directory \
            ) 2>/dev/null
    show:::show_directory
    remove:::show_directory
endgroup
group:_Remove a file or directory
    exec::makemenu: (\
            /usr/share/pdmenu/deldir.pl /var/www "" del_directory \
            ) 2>/dev/null
    show:::del_directory
    remove:::del_directory
endgroup
group:Add a _directory
    exec::makemenu: (\
            /usr/share/pdmenu/adddir.pl /var/www "" add_directory \
            ) 2>/dev/null
    show:::add_directory
    remove:::add_directory
endgroup
group:Add a _file
    exec::makemenu: (\
            /usr/share/pdmenu/addfile.pl /var/www "" add_file \
            ) 2>/dev/null
    show:::add_file
    remove:::add_file
endgroup
nop
 
nop
exit:E_xit
```

you can download the showdir.pl script [here](https://github.com/pbertera/junk/blob/master/showdir/showdir.pl)

All files `/usr/share/pdmenu/editdir.pl` `/usr/share/pdmenu/deldir.pl`
`/usr/share/pdmenu/adddir.pl` `/usr/share/pdmenu/addfile.pl` are symlink to
`showdir.pl`


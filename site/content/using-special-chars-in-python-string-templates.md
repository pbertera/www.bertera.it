Title: Using special chars in Python string Templates
Date: 2013-06-05 21:55
Author: admin
Category: coding, hack
Tags: coding, python, strings, templating
Slug: using-special-chars-in-python-string-templates
Status: published

[PEP-292](http://www.python.org/dev/peps/pep-0292) introduced a nice
Python templating feature.  
Templates placehoder names are subject to some
restrictions,[Documentation](http://docs.python.org/3/library/string.html#template-strings)
says:

    $identifier names a substitution placeholder matching a mapping key of "identifier".
    By default, "identifier" must spell a Python identifier.
    The first non-identifier character after the $ character terminates this placeholder specification.

This means that **\${placeholder}** names must spell the Python
identifier syntax: dots (.), hyphen (-) or other special chars are not
allowed.  
The default regex that must match the placeolder is:

```
r'[\_a-z][\_a-z0-9]\*'  
```

You can simply extend this regex overwriting the **idpattern** property
in **Template** class.

Here a quick example:

```
>>> from string import Template
>>> class MyTemplate(Template):
...     idpattern = r'[a-z][\.\-_a-z0-9]*'
... 
>>> MyTemplate("a=${ciccio_pippo-b}").substitute({'ciccio_pippo-b': "pasticcio"})
'a=pasticcio'
>>> 
```

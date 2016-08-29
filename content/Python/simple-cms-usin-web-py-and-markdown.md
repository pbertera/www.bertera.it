Title: Simple CMS using web.py and Markdown
Date: 2011-11-18 20:54
Author: admin
Tags: python, web.py, webapplications
Slug: simple-cms-usin-web-py-and-markdown
Status: published

With a bit of code you can build a simple but powerful, single page, CMS
using [python](http://www.python.org), [web.py](http://www.webpy.org)
and content stored in [markdown](http://en.wikipedia.org/wiki/Markdown)
files.

1) the application: **application.py**

```
#!/usr/bin/python26
# vi:si:et:sw=4:sts=4:ts=4
# -*- coding: UTF-8 -*-
# -*- Mode: Python -*-
#
# Copyright (C) 2011 Bertera Pietro
 
import web
import mimetypes
 
import markdown2
 
# pages is a list of dictionary: the value of key name represent the name\
# of page, the value of  link represent the routing pattern,
# and content_file is the path of markdown file with the page content
pages = [
        { "name": "Home",
                  "link": "/", 
                  "content_file": "contents/home.md"
                 },
        { "name": "Info",
                  "link": "/info.html", 
                  "content_file": "contents/info.md"
                 },
    ]
 
# this is the directory with static files (images, css, ...)
static_dir = "public"
 
# the view, layout.html is a template file
htmlview = web.template.render('views', cache=False, base="layout",\
   globals={'pages':pages, 'ctx': web.ctx})
 
# generic controller for Markdown pages:
class PageClassTemplate:
    content_file = ""
 
    def GET(self):
        html = markdown2.markdown_path(self.content_file)
        return htmlview.page(html)
 
# Controller for static files
class Public:
    def GET(self):
        try:
            file_name = web.ctx.path.split('/')[-1]
            web.header('Content-type', mime_type(file_name))
            return open('.' + web.ctx.path, 'rb').read()
        except IOError:
            raise web.notfound()
 
# mime type interpreter
def mime_type(filename):
    return mimetypes.guess_type(filename)[0] or 'application/octet-stream'
 
# initialize the application
myApp = web.application(mapping=(), fvars=globals())
 
for page in pages:
    pattern = page["link"]
    globals()[page["name"]] = type(page["name"],\
   (PageClassTemplate,object,), dict(content_file=page["content_file"]))
    myApp.add_mapping(pattern, page["name"])
 
# add static file handler:
try:
    if static_dir:
        myApp.add_mapping("/%s/.+" % static_dir, "Public")
except AttributeError:
    pass
 
# RUN!
if __name__ == "__main__":
    myApp.run()
```

2) main template layout: **views/layout.html**

```
$def with (page, title="")
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="cs" lang="cs">
  <head>
    <title>Single Page Markdown CMS</title>
  </head>
  <body>
 
<h1>
Custom header here      
</h1>
 
    <ul>        
$for item in pages:
    $ attr = ''
    $if ctx.path == item['link']:
        $ attr=' id="current"'
    <li$:(attr)><a href="$item['link']">$item['name']</a></li>
$pass
        </ul>
     
<hr/>
$:page
<hr/>    
 
    Custom footer here 
  </body>
</html>
```

3) content template: views/page.html

```
$def with (html)
 
$:html
```

4) markdown contents:

**contents/home.md**

```
## Welcome !!
 
### This is an Hello word Page!
 
**web.py** the best python framework for webapps [web.py][].
 
This is a simple page from a markdown file
 
  [web.py]: http://www.webpy.org
```

**contents/info.md**  

```
## Info
 
this stupid idea is made by [bertera pietro](http://www.bertera.it)
```

Title: Php sinippet: howto ignore HTTP errors in file_get_contents()
Date: 2011-11-04 12:52
Author: admin
Tags: code, http, php
Slug: php-sinippet-howto-ignore-http-errors-in-file_get_contents
Status: published

A useful snipped of php code:  

```
echo file_get_contents('http://www.example.com/foo.html',\
  FALSE, stream_context_create(array\
  ('http'=>;array('ignore_errors' =>; TRUE))))
```

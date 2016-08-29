Title: How this website works
Date: 2016-06-29 20:25
Author: Pietro
Tags: markdown, Pelican, Docker, github

After many years on Wordpress I decided to move my website to a static website.

I decided to adopt [Pelican](http://blog.getpelican.com/): a static website builder based on python and supporting reStructuredText, Markdown, or AsciiDoc.

Moreover I decided to use [GitHub](https://pages.github.com/) pages to host the website.

The [pdf plugin](https://github.com/pbertera/www.bertera.it/blob/master/plugins/cv_pdf/__init__.py) comes from [Cyrille Rossant](http://cyrille.rossant.net/pelican-github/).

#### Docker

In order to maintain a clean approach I use a self-contained Docker container for managing the whole authoring and publishing / deploying workflow: the [Dockerfile](https://github.com/pbertera/www.bertera.it/blob/master/Dockerfile) defines a container based on the *python:3* image plus all the needed packages and the Flex theme.

The Docker image is automatically build on [Docker hub](https://hub.docker.com/r/pbertera/pelican/)

#### The manage script

The [manage.sh](https://github.com/pbertera/www.bertera.it/blob/master/manage.sh) is a wrapper around the `docker run` command the script accepts all the valid [Makefile](https://github.com/pbertera/www.bertera.it/blob/master/Makefile) target plus the `deploy`, `build` and `update`. The first argument will deploy the website into the `gh-pages` branch, the second one creates the Docker image. The `update` argument is the same of `make html && make serve` inside of the container

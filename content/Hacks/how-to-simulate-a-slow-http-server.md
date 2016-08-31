Title: How to simulate a slow HTTP server with a Dockerized lighttpd
Date: 2016-08-30
Author: pietro
Tags: lighttpd, Docker, testing
Status: published

Today I had to work on an issue related to troubled HTTP connections.
So in order to reproduce such issue I had to find a way to easily reduce the bandwidth of the HTTP transfer.

After a quick Google search I landed on [this](http://stackoverflow.com/a/13656825/143819) Stackoverflow answer 
which suggested me the idea to create a simple Docker container for that.

The container image is automatically build on [Dockerhub](https://hub.docker.com/r/pbertera/lighttpd-throttle/) from the [Dockerfile](https://github.com/pbertera/dockerfiles/blob/master/lighttpd-throttle/Dockerfile).

The container can be easily used to [serve a local folder](https://github.com/pbertera/dockerfiles/tree/master/lighttpd-throttle#server-mode) or as a [proxy](https://github.com/pbertera/dockerfiles/tree/master/lighttpd-throttle#proxy-mode) in front of another HTTP server.

Title: Introducing dcw: a Poor Man PaaS tool
Date: 2017-03-28 22:25
Author: Pietro
Tags: Docker, Bash, SSH

Dcw (Docker Compose Wrapper) is very small and dirty Bash script wrapping the [`docker-compose`](https://docs.docker.com/compose/) command. The meaning of such wrapper is to expose some `docker-compose` [operations](https://docs.docker.com/compose/reference/)  and a set of well defined commands on the host machine.

The typical use-case is an SSH command executed via the `~/.ssh/authorized_keys` file, in this way you can provide provide some `docker-compose` commands that can be execute with some specific `docker-compose` config files.

## The containers pool

A pool is defined via a `docker-compose` YAML config file. The name of the config file defines the pool name.

All the YAML config files must reside into the folder defined via the `dc_confd` variable.

Once you created the config file you are ready to use `dcw` as an SSH command.

## Usage

First of all you have to clone the [git repo](https://github.com/pbertera/dcw):

```bash
$ cd /opt
$ git clone https://github.com/pbertera/dcw
```

The git repository contains a ready to use `docker-compose` config file named `nginx.yaml`.

This file defines a pool of 3 [NGINX](https://www.nginx.com) containers, each container exposes an HTTP and HTTPS port and defines some data volumes, please refer to the [`docker-compose`](https://docs.docker.com/compose/) documentation for the file syntax.

The `nginx.yaml` defines also a label named `management.command.shell` with value `docker exec -it nginx1 /bin/bash`.

Configuring `dcw` is quite simple: you have to properly configure the following variables:

* **dc_confd**: the directory conatining all the docker-compose YAML files (in this case `/opt/dcw`)
* **dc_denied_commands**: (optional) a regex defining all the not allowed `docker-compose`, default `^kill|^rm`
* In case you want to have the [Slack](https://slack.com/) or [HipChat](https://www.hipchat.com/) integration all the other needed vars.

Now you are ready to use dcw into the `~/.ssh/authorized_keys` file: edit the `authorized_keys` in order to use the `dcw` script as an SSH command associated with an SSH public key:

```
command="/opt/dcw/dcw",no-port-forwarding,no-agent-forwarding,no-X11-forwarding ssh-rsa AAAAB3NzaC1 [..] == pietro@hank
```

At this point everything should be ready and you can start using the tool: connect to the remote host using the proper SSH key and user:

```bash
$ ssh pietro.bertera@server help
INFO: SSH Original command: help
Usage:

ssh user@remote-host <pool|command> <args>

Examples:

Run the docker-compose ps over the ldap service pool:
    ssh user@remote-host pool ldap ps

Start the service ldap1 from the ldap pool:
    ssh user@remote-host pool ldap start ldap1

Execute the command defined into the label 'management.command' of the ldap1 container:
    ssh user@remote-host command ldap1 shell

List all the available commands into the container ldap1:
    ssh user@remote-host command ldap1 help
```

List all the containers in the `nginx` pool:

```bash
$ ssh pietro.bertera@server pool nginx ps
INFO: SSH Original command: pool nginx ps
INFO: executing docker-compose ps on nginx
 Name               Command                State                         Ports                     
--------------------------------------------------------------------------------------------------
nginx1   /entrypoint.sh nginx -g da ...   Exit 137   0.0.0.0:10081->443/tcp, 0.0.0.0:10080->80/tcp 
nginx2   /entrypoint.sh nginx -g da ...   Exit 137   0.0.0.0:10083->443/tcp, 0.0.0.0:10082->80/tcp 
nginx3   /entrypoint.sh nginx -g da ...   Exit 137   0.0.0.0:10085->443/tcp, 0.0.0.0:10084->80/tcp 
nginx4   /entrypoint.sh nginx -g da ...   Exit 137   0.0.0.0:10087->443/tcp, 0.0.0.0:10086->80/tcp 
```

Start the container `nginx1`:

```bash
$ ssh pietro.bertera@server pool nginx up -d nginx1
INFO: SSH Original command: pool nginx up -d nginx1
INFO: executing docker-compose up -d nginx1 on nginx
Creating network "nginx_default" with the default driver
Creating nginx1
```

Execute the command defined by the `management.command.shell` Docker label executing the command `docker exec -it nginx1 /bin/bash` on the host, in this case the `-t` SSH option is needed in order to allocate a pseudo terminal:

```bash
$ ssh -t pietro.bertera@server command nginx1 shell
INFO: SSH Original command: command nginx1 shell
INFO: executing command from label management.command.shell into container nginx1
root@23047d54e97b:/#
```

If you configured also the [Slack](https://slack.com/) or [HipChat](https://www.hipchat.com/) integration all the command will be logged on Slack or HipChat too.

## Security

This tool doesn't provide any security feature, so should be used only to provide a simplified way to start/stop containers and execute commands to trusted users only.

For any suggestion, improvement or idea feel free to contact me.

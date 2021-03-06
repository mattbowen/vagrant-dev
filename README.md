Set up my vagrant development box
=======================================

Installation
------------

* Install git, ruby
* Install virtualbox using the packages at [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* run the following commands:

```shell
gem install puppet librarian-puppet
vagrant plugin install vagrant-vbguest
vagrant box add vagrant-dev http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-1204-x64.box
git clone https://github.com/salimane/vagrant-dev.git
cd vagrant-dev/puppet
librarian-puppet install --clean
vagrant up
vagrant ssh
```

Installed components
--------------------

* zsh
* nginx
* golang
* uwsgi + python plugin
* python + virtualenv + pip
* sun jdk 7
* sysctl configurations for lot of connections
* rbenv + rails
* node.js + npm
* percona mysql server
* postgresql
* redis
* memcached
* php-fpm env + xdebug + xhprof + phpunit + boris
* heroku toolbelt
* weighttp


Hints
-----

**Provisioning**

To provision again in case of update or errors while the virtual machine is already up, use:

```shell
vagrant provision
```
It just runs puppet to apply manifests without restarting the virtual machine.


**Startup speed**

To speed up the startup process after the first run, use:

```shell
vagrant up --no-provision
```
It just starts the virtual machine without provisioning of the puppet recipes.


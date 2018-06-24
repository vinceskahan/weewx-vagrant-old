### weewx-vagrant configs

This permits you do easily install weewx under Vagrant/VirtualBox by cloning this repo and doing trivial editing in the Vagrantfile (and possibly the pertinent provisioner script).  See the Vagrantfile for details.


#### tested on

* debian 8 (jessie)
* debian 9 (stretch)
* ubuntu 16.04 LTS (xenial)
* ubuntu 18.04 LTS (bionic)
* centos 6
* centos 7

### to use:
* clone this repo
* edit the Vagrantfile to salt to taste
    * set any VM(s) you want to build to '1' at the top of the Vagrantfile
    * (optionally) tweak the settings just below there
* (optionally) edit the provision.sh script:
    * pick the weewx installation method you want to use
    * set weewx DEBUG=1 or DEBUG=0 as desired
* do 'vagrant up' like any other vagrant configuration
* after 5 minutes, weewx should populate the web content

### notes:
* each VM will expose a different localhost port for the webserver, see the Vagrantfile for details
* the provisioner scripts "should" be directly usable on the target os outside Vagrant

### current status:
* this integrated Vagrantfile has been tested with the 'tgz' method of weewx 3.8.0 only
* previously the 'git' (bleeding edge) and 'pkg' (prepackaged .deb or .rpm) have been tested
* at this time, centos7 uses an init.d file rather than a systemctl service file

### weewx-vagrant configs

This permits you do easily install weewx under vagrant/VirtualBox by cloning this repo and uncommenting a line or two in the Vagrantfile and provision.sh script.  The provision.sh script also can be run standalone on any debian(ish) system that is systemd-based.


#### tested on

* debian 8 (jessie)
* debian 9 (stretch)
* ubuntu 16.04 (trusty)
* ubuntu 17.10 (xenial)
* ubuntu 18.04 (artful)

### to use:
* clone this repo
* edit the Vagrantfile to salt to taste
    * select the base box you want to use
    * set the port you want vagrant to listen on for web traffic
* edit the provision.sh script:
    *  pick the weewx installation method you want to use
    * set weewx DEBUG=1 or DEBUG=0 as desired
* do 'vagrant box add' and 'vagrant up' like any other vagrant configuration
* after 5 minutes, weewx should populate the web content, logging to /var/log/syslog

### notes:
* debian vagrant boxes do not enable Virtual Box vbguest synched folder functionality.  Be sure to have that line commented out in the Vagrantfile

* weewx 3.8.0 dpkg will not install on ubuntu 18.04 (as of 2018-0402) due to ubuntu removing the python-imaging package.  At this time you need to use the setup.py method to install weewx on a ubuntu 18.04 system.  This will require editing your provision.sh script lightly to pick a setup.py-based installation method.


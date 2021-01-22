
## Vagrant files to install weewx v4

This repo contains config files for how to install weewx v4 under Vagrant/VirtualBox. 

* 'pkg' contains config files for using the pre-packaged weewx
* 'setup' contains config files for installing from a tarball

See the subdirectories here for details about how each differs in configuration.

Notes:

* to suppress virtual box guest addition installation, add this to the Vagrantfile
        
    config.vbguest.auto_update = false



Vagrant.configure("2") do |config|

  #------ uncomment which box to use -----

  # config.vm.box = "debian/jessie64"   # debian 8
  # config.vm.box = "debian/stretch64"  # debian 9
  # config.vm.box = "ubuntu/xenial64"   # ubuntu 16.04 LTS
  # config.vm.box = "ubuntu/artful64"   # ubuntu 17.10 
    config.vm.box = "ubuntu/bionic64"   # ubuntu 18.04

  #---- other vm settings, salt to taste ----

  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.provider "virtualbox" do |vb|
   vb.memory = "1024"
   vb.gui = false      # set true to see a virtualbox console
  end
  config.vm.provision :shell, path: "provision.sh"

  # note: the debian vagrant boxes don't have vbguest enabled
  #       so keep this commented out for debian
  #
  # config.vm.synced_folder ".", "/vagrant_data"

end



# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

#---- start editing here ----
# (0=skip 1=use)

RUN_UBUNTU_XENIAL64_TGZ  = 0       # 16.04 LTS     EOL 04/2021
RUN_UBUNTU_BIONIC64_TGZ  = 0       # 18.04 LTS     EOL 04/2021
RUN_DEBIAN_JESSIE64_TGZ  = 1       # debian 8      EOL 06/2020
RUN_DEBIAN_STRETCH64_TGZ = 0       # debian 9      EOL estimated 2022
RUN_CENTOS6_TGZ          = 0       # uses init.d   EOL 11/2020
RUN_CENTOS7_TGZ          = 0       # uses systemd  EOL 06/2024

#---- stop editing here -----

# need one line here for each item above
known_weehosts = {
    "xenial64tgz"  => { :ip => "192.168.33.11", :port => 8811, :mem => 512, :box => "ubuntu/xenial64",  :provisioner => "deb-tgz-systemd.sh"   },
    "bionic64tgz"  => { :ip => "192.168.33.12", :port => 8812, :mem => 512, :box => "ubuntu/bionic64",  :provisioner => "deb-tgz-systemd.sh"   },
    "jessie64tgz"  => { :ip => "192.168.33.13", :port => 8813, :mem => 512, :box => "debian/jessie64",  :provisioner => "deb-tgz-systemd.sh"   },
    "stretch64tgz" => { :ip => "192.168.33.14", :port => 8813, :mem => 512, :box => "debian/stretch64", :provisioner => "deb-tgz-systemd.sh"   },
    "centos6tgz"   => { :ip => "192.168.33.15", :port => 8814, :mem => 512, :box => "centos/6",         :provisioner => "centos-tgz-initd.sh"  },
    "centos7tgz"   => { :ip => "192.168.33.16", :port => 8815, :mem => 512, :box => "centos/7",         :provisioner => "centos-tgz-initd.sh"  },
}

# hold the host definitions that we will actually process
weehosts = {}

# need one 'if' block here per variable you can set to '1' at the top of this file
if RUN_UBUNTU_BIONIC64_TGZ == 1
    weehosts.store("bionic64tgz", known_weehosts["bionic64tgz"])
end
if RUN_UBUNTU_XENIAL64_TGZ == 1
    weehosts.store("xenial64tgz", known_weehosts["xenial64tgz"])
end
if RUN_DEBIAN_JESSIE64_TGZ == 1
    weehosts.store("jessie64tgz", known_weehosts["jessie64tgz"])
end
if RUN_DEBIAN_STRETCH64_TGZ == 1
    weehosts.store("stretch64tgz", known_weehosts["stretch64tgz"])
end
if RUN_CENTOS6_TGZ == 1
    weehosts.store("centos6tgz", known_weehosts["centos6tgz"])
end
if RUN_CENTOS7_TGZ == 1
    weehosts.store("centos7tgz", known_weehosts["centos7tgz"])
end

# to do
# - should exit gracefully if no hosts are enabled at the top of this file

if weehosts.empty?
    puts "EXITING - weehosts empty - please set at least one VM to '1'"
    exit
end

#----- loop through 'weehosts' we have set to be built/used ----

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  weehosts.each_with_index do |(hostname, info), index|


    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|
        config.vm.box = "#{info[:box]}"
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.network "forwarded_port", guest: 80, host: info[:port]
        override.vm.hostname = hostname
        vb.name = hostname
        vb.customize ["modifyvm", :id, "--memory", info[:mem]]
      end # end provider
    end # end config

    # provision weewx on top of the base box
    config.vm.provision :shell, path: info[:provisioner]

  end # end weehosts
end



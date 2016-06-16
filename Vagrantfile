# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  
  # ubuntu 14.04
  config.vm.box = "ubuntu/trusty64"

  # check box for updates
  config.vm.box_check_update = true

  # shared folder between host and guest os
  config.vm.synced_folder "data", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

  # forwarded port mapping
  config.vm.network "private_network", ip: "192.168.20.1"
  
  # host name
  config.vm.hostname = "meanbox1"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end

  # Enable provisioning with a shell script. 
  config.vm.provision "shell", path: "provision.sh"
end

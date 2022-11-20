# -*- coding: utf-8 -*-
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Wymagane pluginy:
#  * vagrant-hostmanager


Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?("vagrant-hostmanager")
      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.ignore_private_ip = false
      config.hostmanager.include_offline = true
  end

  config.vm.define "staging" do |staging|
      staging.vm.box = "ubuntu/jammy64"
      staging.vm.box_check_update = false

      staging.vm.provider "parallels" do |v, override|
        # override.vm.box = "rueian/ubuntu20-m1"
        override.vm.box = "mpasternak/focal64-arm"        
      end

      config.vm.provider "parallels" do |prl|
        prl.memory = 2048
        prl.cpus = 2
      end

      NOW = Time.now.strftime("%d.%m.%Y.%H:%M:%S")
      FILENAME = "serial-debug-%s.log" % NOW
      
      staging.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 2048
        vb.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
        vb.customize [ "modifyvm", :id, "--uartmode1", "file", File.join(Dir.pwd, FILENAME) ]
      end

      staging.vm.hostname = 'bpp-staging'
      if Vagrant.has_plugin?("vagrant-hostmanager")
          staging.hostmanager.aliases = %w(bpp-staging.localnet)
      end

      if Vagrant.has_plugin?("vagrant-timezone")
      	 staging.timezone.value = :host
      end


      staging.vm.network "private_network", ip: "10.0.0.5"
      staging.vm.provision "shell", inline: "sudo dd if=/dev/zero of=/swapfile bs=1M count=1024"
      staging.vm.provision "shell", inline: "sudo mkswap /swapfile"
      staging.vm.provision "shell", inline: "sudo swapon /swapfile"
      staging.vm.provision "shell", inline: "echo swapon /swapfile | sudo tee /etc/rc.local"      
      staging.vm.provision "shell", inline: "sudo apt update"      
      staging.vm.provision "shell", inline: "sudo apt install python3 emacs-nox -y"

      staging.ssh.forward_agent = true
      staging.ssh.forward_x11 = true

      # Prevent SharedFoldersEnableSymlinksCreate errors
      staging.vm.synced_folder ".", '/vagrant', SharedFoldersEnableSymlinksCreate: false

      if Vagrant.has_plugin?("vagrant-cachier")
        # Ten plugin nie jest zarządzany od jakiegoś czasu
        staging.cache.scope = :box
        staging.cache.enable :apt
        staging.cache.enable :npm

        config.cache.synced_folder_opts = {
          owner: "_apt",
        }
      end

  end

end

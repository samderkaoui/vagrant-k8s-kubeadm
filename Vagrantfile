# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  NodeCount = 2  # Changer ici pour ajouter des workers
  
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |node|
      node.vm.box = "almalinux/9"
      node.vm.hostname = "k8s-worker#{i}"
      node.vm.network "private_network", ip: "192.168.10.#{i + 1}"  # worker1: .2, worker2: .3, etc.
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
  
      # Provisioning commun
      node.vm.provision "shell", path: "requirements.sh"
  
      # Provisioning spécifique worker
      node.vm.provision "shell", path: "worker.sh"
    end
  end
  
  # Définition du master
  config.vm.define "master" do |master|
    master.vm.box = "almalinux/9"
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.10.100"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  
    master.vm.provision "shell", path: "requirements.sh"
    master.vm.provision "shell", path: "master.sh"
  end
  
  # Provisioning inline pour /etc/hosts sur TOUTES les machines (automatique !)
  hosts_entries = "192.168.10.100 k8s-master\n"
  (1..NodeCount).each { |i| hosts_entries += "192.168.10.#{i + 1} k8s-worker#{i}\n" }
  
  config.vm.provision "shell", inline: <<-SHELL
    cat <<EOF >/etc/hosts
  127.0.0.1 localhost
  #{hosts_entries}
  EOF
  SHELL

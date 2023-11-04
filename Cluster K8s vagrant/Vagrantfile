# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Change to add more workers
  NodeCount = 2
  
  #global requirements
  config.vm.provision "shell", path: "requirements.sh", :args => NodeCount

  # Kubernetes Master
  config.vm.define "master" do |master|
    master.vm.box = "almalinux/9"
    master.vm.synced_folder '.', '/vagrant' 
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.10.100"
    master.vm.provider "virtualbox" do |v|
      v.name = "k8s-master"
      v.memory = 2048
      v.cpus = 2
    end
    master.vm.provision "shell", path: "master.sh"
    master.vm.box_download_insecure = true
  end

  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box = "almalinux/9"
      worker.vm.synced_folder '.', '/vagrant' 
      worker.vm.hostname = "k8s-worker#{i}"
      worker.vm.network "private_network", ip: "192.168.10.#{i+1}"
      worker.vm.provider "virtualbox" do |v|
        v.name = "k8s-workers#{i}"
        v.memory = 2048
        v.cpus = 2
      end
      worker.vm.provision "shell", path: "worker.sh"
      worker.vm.box_download_insecure = true
    end
  end
end
Vagrant.configure("2") do |config|

    #1- VIRTUAL BOX
    
    
          config.vm.define "virtualbox" do |a|
            a.vm.synced_folder '.', '/vagrant' # ici sur la vm dans /vagrant j'ai le contenu du dossier de mon Vagrant file
            a.vm.box = "ubuntu/mantic64"
            a.vm.hostname = "TestVb"
    
    
            a.vm.network "forwarded_port", guest: 5044, host: 5045, id: 'x'
            a.vm.network "private_network", ip: "192.168.85.215"
    
    # Provisionnement par SHELL (inline et plusieurs lignes )
            a.vm.provision "shell", inline: "echo Hello"
            a.vm.provision "shell" do |s|
              s.inline = <<-SHELL
              sudo dnf install firewalld -y
              sudo systemctl start firewalld
              sudo systemctl enable firewalld
              sudo firewall-cmd --add-port=22/tcp --permanent
              sudo firewall-cmd --reload
              SHELL
    
    #Provisionnement par scripts :
              a.vm.provision:shell, path: "./Ssh_allow_connect_by_pw.sh"
            end
    
    # Provisonnement par ANSIBLE (ansible doit etre installer sur la VM)
    #  Bien pensez a mettre hosts: all dans le playbook sinon marche pas !
    
#              a.vm.provision "ansible_local" do |ansible|
#                ansible.playbook = "/vagrant/leplaybook.yml"
#            end
    
            a.vm.provider "virtualbox" do |vb|
              vb.name = "TestVb"
              vb.memory = "3096"
              vb.cpus = 3
            end 
          end
    
      #fin VIRTUALBOX
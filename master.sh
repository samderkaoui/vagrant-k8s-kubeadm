#!/bin/bash
# Variables
CALICO_VERSION="3.31.3"
IP_MASTER="192.168.56.100"

echo "[TASK 1] PREREQUIS"
sudo firewall-cmd --permanent --add-port={6443,2379,2380,10250,10251,10252,10257,10259,179}/tcp
sudo firewall-cmd --reload


echo "[TASK 2] INITIALISER LE CLUSTER KUBERNETES"
kubeadm init --apiserver-advertise-address=$IP_MASTER --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null


echo "[TASK 3] COPIER LA CONFIGURATION D'ADMIN KUBE DANS LE RÉPERTOIRE .kube DE L'UTILISATEUR VAGRANT"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube


echo "[TASK 4] DÉPLOYER LE RÉSEAU FLANNEL/CALICO"
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/calico.yaml"


echo "[TASK 5] GÉNÉRER ET ENREGISTRER LA COMMANDE DE REJOINDRE LE CLUSTER DANS /VAGRANT/JOINCLUSTER.SH"
kubeadm token create --print-join-command > /vagrant/joincluster.sh 2>/dev/null

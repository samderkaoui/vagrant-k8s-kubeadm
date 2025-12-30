#!/bin/bash

# TUTO https://www.linuxtechi.com/install-kubernetes-on-rockylinux-almalinux/
# Variables
USER_NAME="vagrant"
KUBE_VERSION="1.35.0"  # Ou la dernière stable : vérifier sur kubernetes.io

echo "[TACHE 1] PREREQUIS (paquets , ssh sans clé, update)"
sudo yum install firewalld wget curl vim -y
sudo systemctl start firewalld 
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload

# Vérifiez si "#PasswordAuthentication no" ou "#PasswordAuthentication yes" est présent dans le fichier pour se connecter en ssh via mot de passe
if grep -q "^#PasswordAuthentication no" /etc/ssh/sshd_config; then
    sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo "Modification effectuée pour remplacer '#PasswordAuthentication no' par 'PasswordAuthentication yes'."
elif grep -q "^#PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo "Modification effectuée pour remplacer '#PasswordAuthentication yes' par 'PasswordAuthentication yes2'."
else
    echo "Aucune des lignes spécifiées n'a été trouvée ou la modification a déjà été effectuée."
fi

# Redémarrez le service SSH
sudo systemctl restart sshd
sudo yum update -y


echo "[TACHE 2] MAJ FICHIER HOST"
echo '192.168.10.100 k8s-master' | sudo tee -a /etc/hosts
echo '192.168.10.2 k8s-worker1' | sudo tee -a /etc/hosts
echo '192.168.10.3 k8s-worker2' | sudo tee -a /etc/hosts


echo "[TACHE 3] CONFIGURER CONTAINER RUN TIME (CONTAINERD)"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd


echo "[TACHE 4] DISABLE SWAP"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


echo "[TACHE 5] SELINUX PERMISSIVE"
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux


echo "[TACHE 6] AJOUTER DES MODULES ET DES PARAMÈTRES DU KERNEL"
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter


echo "[TASK 7] Add sysctl settings & apply"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1


echo "[TACHE 8] AJOUT K8S REPO"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF


echo "[TASK 9] INSTALLER KUBERNETES KUBEADM, KUBELET ET KUBECTL"
dnf install -y kubelet-$KUBE_VERSION kubeadm-$KUBE_VERSION kubectl-$KUBE_VERSION --disableexcludes=kubernetes



echo "[TASK 10] ACTIVER ET DÉMARRER LE SERVICE KUBELET"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1



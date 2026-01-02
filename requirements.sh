#!/bin/bash
# Variables
KUBE_REPO_VER="v1.30" # cgroup v1 car almalinux 8 , sinon passer a v 1.31+ avec alma9/10

echo "[TACHE 1] PREREQUIS (paquets , SSH, firewall)"
#sudo dnf update -y
sudo rpm --import https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux
sudo dnf upgrade -y almalinux-release
sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install wget curl vim containerd.io container-selinux -y
sudo dnf clean all
sudo systemctl start containerd
sudo systemctl enable containerd


echo "[TACHE OPTIM] ALLÉGER ALMALINUX"
sudo systemctl disable --now firewalld auditd gssproxy irqbalance polkit postfix avahi-daemon cups bluetooth libvirtd rpcbind
#sudo dnf install -y firewalld
#sudo systemctl enable --now firewalld
#sudo firewall-cmd --permanent --add-service=ssh
#sudo firewall-cmd --reload




echo "[TACHE 2] MODULES KERNEL ET SYSCTL (Indispensable avant containerd)"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system >/dev/null 2>&1


echo "[TACHE 3] CONFIGURER CONTAINER RUNTIME (CONTAINERD)"
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
# Activation du support Systemd pour les Cgroups
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd


echo "[TACHE 4] DISABLE SWAP & SELINUX"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux


echo "[TACHE 5] AJOUT K8S REPO"
# Note l'utilisation de KUBE_REPO_VER pour le chemin de l'URL
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${KUBE_REPO_VER}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${KUBE_REPO_VER}/rpm/repodata/repomd.xml.key
EOF


echo "[TACHE 6] INSTALLER KUBEADM, KUBELET, KUBECTL"
# On utilise dnf install sans les versions si on veut la toute dernière du repo
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

echo "[TACHE 7] SLEEP 10s"
sleep 10

echo "[TACHE 8] Clean"
sudo dnf autoremove
sudo dnf clean all

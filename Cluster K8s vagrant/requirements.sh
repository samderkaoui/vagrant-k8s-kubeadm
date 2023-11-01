#!/bin/bash

# TUTO https://www.linuxtechi.com/install-kubernetes-on-rockylinux-almalinux/
# Variables
USER_NAME="vagrant"

echo "[TACHE 1] PREREQUIS (paquets , ssh sans clé, update)"

sudo yum install firewalld wget curl vim -y
sudo systemctl start firewalld 
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload
# Vérifiez si "#PasswordAuthentication no" ou "#PasswordAuthentication yes" est présent dans le fichier
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
# sudo yum update -y





echo "[TACHE 2] MAJ FICHIER HOST"
echo '192.168.10.100 k8s-master' | sudo tee -a /etc/hosts
echo '192.168.10.101 k8s-worker1' | sudo tee -a /etc/hosts
echo '192.168.10.102 k8s-worker2' | sudo tee -a /etc/hosts







echo "[TACHE 3] INSTALL DOCKER / DOCKER COMPOSE"
sudo dnf remove -y podman buildah
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
# Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Ajouter l'utilisateur $USER_NAME au groupe docker
sudo usermod -aG docker $USER_NAME






echo "[TACHE 4] CONFIGURE / ENABLE & START DOCKER"
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl enable docker >/dev/null 2>&1
systemctl daemon-reload
systemctl restart docker







echo "[TACHE 5] CONFIGURER CONTAINER RUN TIME (CONTAINERD)"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd






echo "[TACHE 6] DISABLE SWAP"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab





echo "[TACHE 7] SELINUX PERMISSIVE"
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux






echo "[TACHE 8] AJOUTER DES MODULES ET DES PARAMÈTRES DU KERNEL"
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Add sysctl settings
echo "[TASK 4] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply
sysctl --system >/dev/null 2>&1







echo "[TACHE 9] AJOUT K8S REPO"
cat <<EOF | sudo tee /etc/yum.repos.d/k8srpm.repo
[k8s]
name=k8s
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# Les paquets kubelet kubeadm et kubectl
#  sont exclus afin d’éviter tout update ultérieure non intentionnelle.





echo "[TASK 10] INSTALLER KUBERNETES KUBEADM, KUBELET ET KUBECTL"
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=k8s



# Start and Enable kubelet service
echo "[TASK 11] ACTIVER ET DÉMARRER LE SERVICE KUBELET"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1



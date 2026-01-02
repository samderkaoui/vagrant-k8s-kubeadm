#!/bin/bash
# Variables
#CALICO_VERSION="3.31.3"
IP_MASTER="192.168.56.100"

#echo "[TACHE 1] PREREQUIS FIREWALLD"
#sudo firewall-cmd --permanent --add-service=ssh
#sudo firewall-cmd --permanent --add-port={6443,2379,2380,10250,10251,10252,10257,10259,179}/tcp
#sudo firewall-cmd --reload


echo "[TACHE 2] INITIALISER LE CLUSTER KUBERNETES"
sudo kubeadm init --apiserver-advertise-address=$IP_MASTER --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///run/containerd/containerd.sock --v=4

echo "[TACHE 3] COPIER LA CONFIGURATION D'ADMIN KUBE DANS LE RÉPERTOIRE .kube DE L'UTILISATEUR VAGRANT"
mkdir /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
sleep 20

echo "[TACHE 4] RETIRER LE TAINT DU MASTER POUR Y DÉPLOYER DES PODS (OPTIONNEL)"
su - vagrant -c "kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-"
sleep 5

echo "[TACHE 5] DÉPLOYER LE RÉSEAU FLANNEL"
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
sleep 5

echo "[TACHE 6] CONFIGURER FLANNEL POUR UTILISER LA BONNE INTERFACE RÉSEAU (enp0s8)"
su - vagrant -c "kubectl patch daemonset kube-flannel-ds -n kube-flannel --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--iface=enp0s8"}
]'
"

sleep 15

echo "[TACHE 7] DÉPLOYER METRICS-SERVER"
su - vagrant -c "kubectl apply -f /vagrant/metrics-server.yaml"

echo "[TACHE 8] GÉNÉRER ET ENREGISTRER LA COMMANDE DE REJOINDRE LE CLUSTER DANS /VAGRANT/JOINCLUSTER.SH"
sudo kubeadm token create --print-join-command > /vagrant/joincluster.sh 2>/dev/null

echo "[TACHE 9] INSTALLER K9S"
su - vagrant -c "curl -sS https://webi.sh/k9s | sh"
su - vagrant -c "source ~/.config/envman/PATH.env"


echo "[TACHE 10] DÉPLOYER LE DASHBOARD KUBERNETES"
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml"
sleep 15

echo "[TACHE 11] CRÉER LE SERVICEACCOUNT ET LE CLUSTERROLEBINDING POUR ACCÉDER AU DASHBOARD"
su - vagrant -c "
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
EOF
"
su - vagrant -c "
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: dashboard-admin
  namespace: kubernetes-dashboard
EOF
"

echo "[TACHE 12] GÉNÉRER LE JETON D'ACCÈS POUR LE DASHBOARD ET L'ENREGISTRER DANS /VAGRANT/TOKEN_DASHBOARD.TXT"
su - vagrant -c "kubectl -n kubernetes-dashboard create token dashboard-admin > /vagrant/token_dashboard.txt"
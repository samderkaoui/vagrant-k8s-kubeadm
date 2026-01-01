#!/bin/bash

echo "[TACHE 1] PREREQUIS"
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-port={179,10250,30000-32767}/tcp
sudo firewall-cmd --reload


echo "[TACHE 2] REJOINDRE LE NŒUD AU CLUSTER KUBERNETES"
bash /vagrant/joincluster.sh 2>/dev/null


echo "===================================="
echo 'run command: vagrant ssh master -c "kubectl get nodes -o wide"'
echo "===================================="

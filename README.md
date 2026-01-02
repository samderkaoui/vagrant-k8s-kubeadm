# vagrant-k8s-kubeadm - ALMALINUX 9

`tuto install : https://www.linuxtechi.com/install-kubernetes-on-rockylinux-almalinux/`

`badges : https://gist.github.com/kimjisub/360ea6fc43b82baaf7193175fd12d2f7`

---
[![tag](https://img.shields.io/badge/-Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](none)
[![tag](https://img.shields.io/badge/-VirtualBox-183A61?style=flat&logo=virtualbox&logoColor=white)](none)
[![Vagrant](https://img.shields.io/badge/-Vagrant-1868F2?style=flat&logo=vagrant&logoColor=white)](none)
[![tag](https://img.shields.io/badge/-Shell-FFD500?style=flat&logo=shell&logoColor=white)](none)
[![tag](https://img.shields.io/badge/-AlmaLinux-000000?style=flat&logo=almalinux&logoColor=white)](none)
## Overview

Ce projet vise l'installation d'un cluster complet K8s avec un nombre de worker à definir.

Status du projet : 

- [x] Distribution : Almalinux 8.8
  - [x] Latest version de kubernetes **(1.30)** supporté par la distribution (car cgroups v1)
  - [x] Utilisation de Flannel (calico erreur avec interface Virtualbox flemme de creuser => Cilium alma9 :) )
  - [x] Désactivation firewalld
  - [x] Ajout Métrics server
  - [x] Ajout dans script master.sh Un-Taint node master
  - [x] Ajout Kubernetes Dashboard
  - [x] Fixer install auto de k9s
  - [x] Optimisation Almalinux et nettoyage DNF
  - [x] Ajout kubens/kubectx
  - [ ] Choisir un Gateway (Ingress trop vieux, on passe à la Gateway API ! 🚀) => [![tag](https://img.shields.io/badge/Istio-466BB0?style=for-the-badge&logo=Istio&logoColor=white)](none)

- TO DO
- [ ] Distribution : Almalinux 9 (car Cilium a besoin du Kernel 5 et Almalinux 8 est en 4.x)
  - [ ] Basculer de Calico vers Cilium pour passer à une architecture eBPF plus légère et performante : cela réduit l'overhead système en remplaçant kube-proxy et permettra de supprimer les lenteurs d'iptables, obtenir une visibilité totale sur le trafic avec Hubble et de sécuriser les flux au niveau applicatif (L7, plus granulaire, avec HTTP, requetes etc...) plutôt que par simples adresses IP
---

> **Table of Contents**:
>
> * [Lancement du cluster](#installer-cluster)
> * [Configuration](#configuration)
>   * [Ajout workers](#ajout-workers)
>   * [Changer nom worker](#changement-nom-worker)
> * [Recapitulatif Machines](#recapitulatif-machines)
---

## Installer cluster

```ruby
vagrant up
```

```bash
# Régler soucis de DHCP sur Virtualbox
1- Ouvre VirtualBox GUI sur ton host (Ubuntu).
2- Va dans File → Host Network Manager (ou Preferences → Network sur certaines versions).
3- Sélectionne l'interface vboxnet0 (celle avec 192.168.56.1).
4- Clique sur l'onglet DHCP Server.
5- Décoche "Enable Server" (désactive le DHCP).
6- Applique (OK).
```

## Configuration

### Ajout workers

Changer NodeCount dans le Vagrantfile
```ruby
Vagrant.configure(2) do |config|

  NodeCount = 2  # Changer ici pour ajouter des workers
```


### Changement nom worker
```bash
kubectl label nodes worker1 node-role.kubernetes.io/worker=worker
```

## Id/pw
vagrant/vagrant

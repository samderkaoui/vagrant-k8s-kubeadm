# vagrant-k8s-kubeadm - ALMALINUX 9

**[Tuto Install](https://www.linuxtechi.com/install-kubernetes-on-rockylinux-almalinux/)**

[![tag](https://img.shields.io/badge/VirtualBox-21416b?style=for-the-badge&logo=VirtualBox&logoColor=white)](https://www.google.fr)
[![tag](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)](none)
[![Vagrant](https://img.shields.io/badge/Vagrant-1868F2?style=for-the-badge&logo=Vagrant&logoColor=white)](none)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

## Overview

Ce projet vise l'installation d'un cluster complet K8s avec un nombre de worker à definir.

Status du projet :

- [x] Compatible Almalinux 8
  - [x] Latest version de kubernetes supporté par la distribution  testé et validé car cgroups v1 **(1.30)**
  - [x] Utilisation de Calico v **(3.31.3)**

To do 
  - [] Basculer vers cilium (plus rapide, eBPF etc)
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
# vérifier que tout est ok sur master / ou juste faire depuis master 'kubectl get nodes -o wide'
vagrant ssh master -c 'kubectl get nodes -o wide'
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

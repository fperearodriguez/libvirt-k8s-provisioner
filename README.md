# K8S on KVM - dedicated server
Provision a Kubernetes cluster by using [libvirt-k8s-provisioner](https://github.com/kubealex/libvirt-k8s-provisioner).

## Prerequisites
Clone the _libvirt-k8s-provisioner_ repository:
```bash
git clone git@github.com:kubealex/libvirt-k8s-provisioner.git
```

Edit the [inventory](./libvirt-k8s-provisioner/inventory) file and set your KVM host.

Install required collections:
```bash
ansible-galaxy collection install -r libvirt-k8s-provisioner/requirements.yml
```

## Environment plan
The installer reads a vars file located under the [vars](./libvirt-k8s-provisioner/vars) folder. In this file we can set the K8S cluster's requirements.

**TIP:** By default, the installer uses a file called _k8s_cluster.yml_. In order to be able to create multiple clusters, multiple vars files can be created and the file's prefix name must be set as variable when executing _ansible-playbook_ command.

For example, to use the file ***vars/k8s-1_cluster.yml***, run:
```bash
ansible-playbook main.yaml --extra-vars "k8s_cluster_name=k8s-1"
```

Ensure that you use a different _k8s.cluster_name,k8s.network.domain and k8s.network.network_cidr variables_.

## Provisioning a cluster
To create a K8S cluster, execute:
```bash
ansible-playbook main.yaml --extra-vars "k8s_cluster_name=<cluster-name>"
```

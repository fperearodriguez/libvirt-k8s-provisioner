# K8S on KVM
Provision a Kubernetes cluster by using [libvirt-k8s-provisioner](https://github.com/kubealex/libvirt-k8s-provisioner).

## Prerequisites
Edit the [inventory](./libvirt-k8s-provisioner/inventory) file and set your KVM host.

Install required collections:
```bash
ansible-galaxy collection install -r libvirt-k8s-provisioner/requirements.yml
```

## Environment plan
The installer reads a vars file located under the [vars](./libvirt-k8s-provisioner/vars) folder. In this file we can set the K8S cluster's requirements.

>:mag_right: By default, the installer uses a file called _k8s_cluster.yml_. In order to be able to create multiple clusters, multiple vars files can be created and the file's prefix name must be set as variable when executing _ansible-playbook_ command.

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

## MultiCluster
The installer is able to provision multiple clusters in the same KVM network. For it, under the _network_ section in the vars file, the value **existing** must be added. Let's take a look at the sample below:

**cluster-1**

```bash
  network:
    network_cidr: 192.168.10.0/24
    domain: shared-domain.example.internal
    ...
    existing:
      role: primary
      name: shared-domain
```

**cluster-2**

```bash
  network:
    network_cidr: 192.168.10.0/24
    domain: shared-domain.example.internal
    ...
    existing:
      role: secondary
      name: shared-domain
```

* **network_cird**: Same value in both vars files.
* **domain**: Same value in both vars files.
* **role**:
  * Primary: KVM network is created.
  * Secondary: Use existing KVM network.
* **name**: KVM network's name.

> :warning: Since Terraform is used, the **primary** cluster must be deleted the last. Otherwise, the delete process will be fail.

Once the vars files are set, provision both cluster:

1. First, primary cluster (KVM network is created here):

```bash
ansible-playbook main.yaml --extra-vars "k8s_cluster_name=cluster-1"
```

2. Once the cluster is installed, provision the second one:

```bash
ansible-playbook main.yaml --extra-vars "k8s_cluster_name=cluster-2"
```



## Merge kubeconfig
The installer can merge the cluster's kubeconfig with your Kubeconfig. To do so, in the _vars_ file, enable it:

```bash
k8s:
  ...
  merge_kubeconfig: true
  ...
```


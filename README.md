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

# Multiple clusters in different networks
Follow the example above to provision multiple clusters in different networks. This is an example of network configuration for each cluster:

**hub cluster**

```bash
  network:
    network_cidr: 192.168.100.0/24
    domain: k8s-hub.example.internal
    additional_san: ""
    pod_cidr: 10.20.0.0/16
    service_cidr: 10.110.0.0/16
    existing:
      role: primary
      name: k8s-hub
```

**cluster-1**

```bash
  network:
    network_cidr: 192.168.101.0/24
    domain: k8s-1.example.internal
    additional_san: ""
    pod_cidr: 10.21.0.0/16
    service_cidr: 10.111.0.0/16
    existing:
      role: primary
      name: k8s-1
```

**cluster-2**

```bash
  network:
    network_cidr: 192.168.102.0/24
    domain: k8s-2.example.internal
    additional_san: ""
    pod_cidr: 10.22.0.0/16
    service_cidr: 10.112.0.0/16
    existing:
      role: primary
      name: k8s-2
```

Provision the **hub cluster**:
```bash
ansible-playbook main.yml --extra-vars "k8s_cluster_name=k8s-hub"
```

Provision the **cluster-1** cluster:
```bash
ansible-playbook main.yml --extra-vars "k8s_cluster_name=k8s-1"
```

Provision the **cluster-2** cluster:
```bash
ansible-playbook main.yml --extra-vars "k8s_cluster_name=k8s-2"
```

> :warning: [Routed network](https://libvirt.org/formatnetwork.html#routed-network-config) is used in this scenario, so it requires routing configuration in the host server.

Following the example below:
| Name                 | Value              |
| -----------          | -----------        |
| Host interface       | eth0               |
| KVM interface        | virbr1             |

Execute in the host server:
```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A INPUT -i virbr1 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -j ACCEPT
```

# Multiple clusters in same network
Follow the example below to provision multiple clusters in the same network. This is an example of network configuration for each cluster:

**cluster-1**

```bash
  network:
    network_cidr: 192.168.100.0/24
    domain: k8s.example.internal
    additional_san: ""
    pod_cidr: 10.21.0.0/16
    service_cidr: 10.111.0.0/16
    existing:
      role: primary
      name: k8s
```

**cluster-2**

```bash
  network:
    network_cidr: 192.168.100.0/24
    domain: k8s.example.internal
    additional_san: ""
    pod_cidr: 10.22.0.0/16
    service_cidr: 10.112.0.0/16
    existing:
      role: secondary
      name: k8s
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

# Merge kubeconfig
The installer can merge the cluster's kubeconfig with your Kubeconfig. To do so, in the _vars_ file, enable it:

```bash
k8s:
  ...
  merge_kubeconfig: true
  ...
```

# Cleanup
To delete an existing cluster:
```bash
ansible-playbook 99_cleanup.yml --extra-vars "k8s_cluster_name=<cluster-name>"
```


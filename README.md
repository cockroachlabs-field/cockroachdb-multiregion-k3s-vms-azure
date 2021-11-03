# CockroachDB Azure Multi Region Demo (Manual)

In this demo you will deploy CockroackDB across three Azure Regions. Region one and two will be running a K3s Kubernetes Cluster and the third region will be three virtual machines.

## Prereqs

To complete this demo you will allready need the following.

- Three Virtual Networks in three different regions without overlapping address space.
- Three subnets, one in each Virtual Network.
- Three virtual machines (Ubuntu 20.04 was used to create this demo) in each region with a NIC connected to the corrasponding subnet.
- For security best practise, each virtual machine should have a Network Security Group (NSG) associated with its network adaptor.

## Network Secrity Rules

|Source|Destination|Port Number|
|------|-----------|-----------|
|Host Workstation|Kubernetes API|6443|
|Host Workstation |SSH Access to Each VM|22|

## Build Steps

The first step is to install a K3s master node making sure to disable support for the default CNI plugin and the built-in network policy enforcer.
To do this we will be using [k3sup](https://github.com/alexellis/k3sup) (said 'ketchup'). [k3sup](https://github.com/alexellis/k3sup) is a light-weight utility to get from zero to KUBECONFIG with k3s on any local or remote VM. All you need is ssh access and the k3sup binary to get kubectl access immediately.


1. The first step is to install [k3sup](https://github.com/alexellis/k3sup) on the the host workstation you will be using to configure the demo enviroment. This could be your workstation or a dedicated builder machine.

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup --help
```
2. Next we need to deploy [k3s](https://github.com/k3s-io/k3s) on to our first virtual machine in region one. Use the [k3sup](https://github.com/alexellis/k3sup) command below to install the first node. Be sure to repace (Public IP) with the public IP of the node.

```
k3sup install \
  --ip=(Public IP) \
  --user=azureuser \
  --sudo \
  --cluster \
  --k3s-channel=stable \
  --k3s-extra-args '--flannel-backend none --disable-network-policy' \
  --merge \
  --local-path $HOME/.kube/config \
  --context=k3s-cl1
```

3. Next you can add the agent nodes to the [k3s](https://github.com/k3s-io/k3s) This will be where are workloads are ran from. In this example we are going to add three agents.
```
Deploy Agents
```

4. So now we have a single cluster in one region we can now move on to the deployment of [k3s](https://github.com/k3s-io/k3s) to our second region. The command below is similar to the command is step two but we need to ensure we use the Public IP of the first node in our second region. 
Deploy Second k3s cluster
```
k3sup install \
  --ip=(Public IP) \
  --user=azureuser \
  --sudo \
  --cluster \
  --k3s-channel=stable \
  --k3s-extra-args '--flannel-backend none --disable-network-policy' \
  --merge \
  --local-path $HOME/.kube/config \
  --context=k3s-cl2
```

5. Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).
```
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}
```

6. Now that we have installed the Cilium CLI we can use it to install the Cilium CNI on to our first [k3s](https://github.com/k3s-io/k3s) cluster. First we ensure we are using the correct context.  
```
kubectl config use-context k3s-cl1
cilium install --config cluster-pool-ipv4-cidr=10.10.0.0/16 --cluster-name=k3s-cl1 --cluster-id=1
```
7. Repeat for cluster 2

Propergate Cilium CA Secret form one cluster to the other.
```
kubectl get secret cilium-ca -n kube-system -o yaml > cilium-ca.yaml
kubectx k3s-cl2
kubectl create -f  cilium-ca.yaml
```

Install  Cilium on cluster 2

If you are planning to run Hubble Relay across clusters, it is best to share a certificate authority (CA) between the clusters as it will enable mTLS across clusters to just work.

The easiest way to establish this is to pass --inherit-ca to the install command when installing additional clusters:
```
cilium install  --config cluster-pool-ipv4-cidr=10.11.0.0/16 --cluster-name=k3s-cl2 --cluster-id=2 
```

If you are not using cilium install for the installation, simply propagate the Kubernetes secret containing the CA from one cluster to the other.

Enable clustermesh
```
cilium clustermesh enable --context k3s-cl1 --service-type LoadBalancer
cilium clustermesh enable --context k3s-cl2 --service-type LoadBalancer
```

Check Status
```
cilium clustermesh status --context k3s-cl1 --wait
cilium clustermesh status --context k3s-cl2 --wait
```

Connect the clusters together...
```
cilium clustermesh connect --context k3s-cl1 --destination-context k3s-cl2
```


Set kubeconfig to the below...
```
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

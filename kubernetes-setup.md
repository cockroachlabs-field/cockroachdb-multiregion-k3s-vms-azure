# Kubernetes Setup

Description: Setting up and configuring Kubernetes in tow of the three regions. Each cluster will be made up of three nodes.

The first step is to install a K3s LEADER node. To do this we will be using [k3sup](https://github.com/alexellis/k3sup) (said 'ketchup'). [k3sup](https://github.com/alexellis/k3sup) is a light-weight utility to get from zero to KUBECONFIG with k3s on any local or remote VM. All you need is ssh access and the k3sup binary to get kubectl access immediately.


- The first step is to install [k3sup](https://github.com/alexellis/k3sup) on the the host workstation you will be using this to configure the demo environment. This could be your workstation or a dedicated builder machine.

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup --help
```

- Next we need to deploy [k3s](https://github.com/k3s-io/k3s) on to our first virtual machine in region one. Use the [k3sup](https://github.com/alexellis/k3sup) command below to install the first node. Be sure to replace (Public IP) with the public IP of the node.

You can retrieve the Public IP address of the first node in region one with the command below.

```
LEADERR1=$(az vm show -d -g $rg  -n crdb-$loc1-node1 --query publicIps -o tsv)
```

- Now use [k3sup](https://github.com/alexellis/k3sup) to create the first Kubernetes cluster.

```
k3sup install \
  --ip=$LEADERR1 \
  --user=ubuntu \
  --sudo \
  --cluster \
  --k3s-channel stable \
  --merge \
  --local-path $HOME/.kube/config \
  --context=$clus1
```

- Next you can add the agent nodes to the [k3s](https://github.com/k3s-io/k3s) cluster. This will be where are CockroachDB workloads will be ran from. In this example we are going to add two agents.

Obtain the Public IP address of the second node.

```
AGENT1R1=$(az vm show -d -g $rg  -n crdb-$loc1-node2 --query publicIps -o tsv)
```

- Now use [k3sup](https://github.com/alexellis/k3sup) to add the node to the existing cluster.

```
k3sup join \
  --ip $AGENT1R1 \
  --user ubuntu \
  --sudo \
  --k3s-channel stable \
  --server \
  --server-ip $LEADERR1 \
  --server-user ubuntu \
  --sudo
```
Repeat this for the third node.

- Obtain the Public IP address of the third node.

```
AGENT2R1=$(az vm show -d -g $rg  -n crdb-$loc1-node3 --query publicIps -o tsv)
```

- Now use [k3sup](https://github.com/alexellis/k3sup) to add the node to the existing cluster.

```
k3sup join \
  --ip $AGENT2R1 \
  --user ubuntu \
  --sudo \
  --k3s-channel stable \
  --server \
  --server-ip $LEADERR1 \
  --server-user ubuntu \
  --sudo
```

- So now we have a single cluster in one region we can now move on to the deployment of [k3s](https://github.com/k3s-io/k3s) in our second region. The command below is similar to the command is step two but we need to ensure we use the Public IP of the first node in our second region.

To deploy Second k3s cluster, retrieve the Public IP address of the first node in region two.

```
LEADERR2=$(az vm show -d -g $rg  -n crdb-$loc2-node1 --query publicIps -o tsv)
```

Now use [k3sup](https://github.com/alexellis/k3sup) to create the second Kubernetes cluster.

```
k3sup install \
  --ip=$LEADERR2 \
  --user=ubuntu \
  --sudo \
  --cluster \
  --k3s-channel=stable \
  --merge \
  --local-path $HOME/.kube/config \
  --context=$clus2
```

- Next you can add the agent nodes to the [k3s](https://github.com/k3s-io/k3s) cluster. This will be where are CockroachDB workloads are ran from. In this example we are going to add two agents.

Obtain the Public IP address of the second node.

```
AGENT1R2=$(az vm show -d -g $rg  -n crdb-$loc2-node2 --query publicIps -o tsv)
```

Now use [k3sup](https://github.com/alexellis/k3sup) to add the node to the existing cluster.

```
k3sup join \
  --ip $AGENT1R2 \
  --user ubuntu \
  --sudo \
  --k3s-channel stable \
  --server \
  --server-ip $LEADERR2 \
  --server-user ubuntu \
  --sudo
```

- Repeat this for the third node.

Obtain the Public IP address of the third node.

```
AGENT2R2=$(az vm show -d -g $rg  -n crdb-$loc2-node3 --query publicIps -o tsv)
```

- Now use [k3sup](https://github.com/alexellis/k3sup) to add the node to the existing cluster.

```
k3sup join \
  --ip $AGENT2R2 \
  --user ubuntu \
  --sudo \
  --k3s-channel stable \
  --server \
  --server-ip $LEADERR2 \
  --server-user ubuntu \
  --sudo
```

Now you are ready to move to the next step. [Cockroach setup](cockroach-setup.md)

[Back](README.md)

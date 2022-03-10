
# CockroachDB Multi-Region Custer with a mix of k3s Kubernetes and Virtual Machines nodes running in Azure (Manual)

In this demo you will deploy CockroachDB across three Azure Regions. Two regions will be running a K3s Kubernetes cluster and the third region will be running Ubuntu based Virtual Machines. This is to demonstrate the flexibility that can be achieved in a variety of deployments scenarios.

## Requirements

This solution will deliver the following requirements.

- Deploy a Multi Region CockroachDB solution in Azure. 
- Two regions in Kubernetes.
- One region running on Virtual Machines.

## Prerequisites 

To complete this demo you will already need the following.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [k3sup](https://github.com/alexellis/k3sup)
- [Cilium CLI](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## Deployment Steps

To complete this demo there are a number of steps. These are listed below.

1. [Azure infrastructure setup](azure-infra-setup.md)
1. [Kubernetes setup](kubernetes-setup.md)
1. [CockroachDB setup](cockroach-setup.md)
1. [Virtual Machine setup](vm-setup.md)

## Clean Up

Creating resources in Azure costs money, so make sure you delete the Resource Group once you’re finished.
```
az group delete --name $rg
rm ~/.kube/config
touch ~/.kube/config
cat ~/.kube/config
```
## Conclusion

In some use cases it may be necessary to mix different deployment patterns for your CockroachDB cluster. It is possible to mix Kubernetes Pods and virtual machines as you have seen in this demo. This is achieved by exposing the Kubernetes pods via the host network. Typically I would not recommend this approach as it reduces the mobility of your application pods as they are tied to a single node. However in the case of CockroachDB it is typical to do this due to the resource requirements of each pod. The main challenge I found with this deployment pattern was that virtual machines and Kubernetes rely on their own deployment of DNS. For this solution to function we need to ensure that both instances of DNS work in harmony. This has been done by hosting a Private DNS Zone in Azure and forwarding requests from CoreDNS to Azure. This ensures that all the pods are able to successfully resolve the names of all the nodes that make up the cluster, whether they are pods in Kubernetes or virtual machines. This demo shows the true flexibility of CockroachDB and how it can be deployed across many different platforms, its architecture of a single binary makes it incredibly easy to deploy and ideal to run inside a container. Give it a go!
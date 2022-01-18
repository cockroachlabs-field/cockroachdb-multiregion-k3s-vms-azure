
# CockroachDB Azure Multi Region Demo with k3s (Manual)

In this demo you will deploy CockroachDB across three Azure Regions. Regions will be running a K3s Kubernetes. This is to demonstrate the flexibility that can be achieved in a variety of deployments scenarios.

## Requirements

This solution will deliver the following requirements.

- Deploy a Multi Region CockroachDB solution in either one or more cloud providers. 
- Three regions in Kubernetes.
- Implement split node certificates.
- Implement pgpool and/or pgbouncer.
- Attach an application to the application.


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
rm /Users/mikebookham/.kube/config
touch /Users/mikebookham/.kube/config
cat /Users/mikebookham/.kube/config
```
## Conclusion

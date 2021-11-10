
# UNDER DEVELOPMENT CockroachDB Azure Multi Region Demo (Manual)

In this demo you will deploy CockroackDB across three Azure Regions. Region one and two will be running a K3s Kubernetes Cluster and the third region will be three virtual machines.

## Requirements

- Deploy a Multi Region CockroachDB solution in either one or more cloud providers. 
- Two regions in Kubernetes and on Virtual Machines.
- Implement split node certificates.
- Implement pgpool and/or pgbouncer.
- Attach an application to the application.


## Prereqs

To complete this demo you will allready need the following.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [k3sup](https://github.com/alexellis/k3sup)

## Network Secrity Rules

|Source|Destination|Port Number|
|------|-----------|-----------|
|Host Workstation|Kubernetes API|6443|
|Host Workstation |SSH Access to Each VM|22|


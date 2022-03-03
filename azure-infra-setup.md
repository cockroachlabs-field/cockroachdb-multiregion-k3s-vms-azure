# Azure Infrastructure Setup

Description: Setting up and configuring all the required infrastructure to support a multi region cockroach cluster on Azure

## Create a set of variables

```bash
export vm_type="Standard_DS2_v2"
export rg="bookham-k3s-multi-region"
export clus1="crdb-k3s-eastus"
export clus2="crdb-k3s-westus"
export clus3="crdb-k3s-northeurope"
export loc1="eastus"
export loc2="westus"
export loc3="northeurope"
export dnsname="private.cockroach.internal"
```

## Create the required Azure Resources

- Create a Resource Group for the project

```bash
az group create --name $rg --location $loc1
```

- Networking configuration

In order to enable VNet peering between the regions, the CIDR blocks of the VPCs must not overlap. This value cannot change once the cluster has been created, so be sure that your IP ranges do not overlap.

- Create vnets for all Regions


```bash
az network vnet create -g $rg -l $loc1 -n crdb-$loc1 --address-prefix 10.1.0.0/16 \
    --subnet-name crdb-$loc1-sub1 --subnet-prefix 10.1.1.0/24
az network vnet create -g $rg -l $loc2 -n crdb-$loc2 --address-prefix 10.2.0.0/16 \
    --subnet-name crdb-$loc2-sub1 --subnet-prefix 10.2.1.0/24
az network vnet create -g $rg -l $loc3 -n crdb-$loc3 --address-prefix 10.3.0.0/16 \
    --subnet-name crdb-$loc3-sub1 --subnet-prefix 10.3.1.0/24
```

- Peer the Vnets

```bash
az network vnet peering create -g $rg -n $loc1-$loc2-peer --vnet-name crdb-$loc1 \
    --remote-vnet crdb-$loc2 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create -g $rg -n $loc2-$loc3-peer --vnet-name crdb-$loc2 \
    --remote-vnet crdb-$loc3 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create -g $rg -n $loc1-$loc3-peer --vnet-name crdb-$loc1 \
    --remote-vnet crdb-$loc3 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create -g $rg -n $loc2-$loc1-peer --vnet-name crdb-$loc2 \
    --remote-vnet crdb-$loc1 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create -g $rg -n $loc3-$loc2-peer --vnet-name crdb-$loc3 \
    --remote-vnet crdb-$loc2 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create -g $rg -n $loc3-$loc1-peer --vnet-name crdb-$loc3 \
    --remote-vnet crdb-$loc1 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
```

- Create a DNS Private Zone for name resolution for all region.

```
az network private-dns zone create -g $rg \
   -n $dnsname

az network private-dns link vnet create -g $rg -n $loc1-DNSLink \
   -z $dnsname -v crdb-$loc1 -e true

az network private-dns link vnet create -g $rg -n $loc2-DNSLink \
   -z $dnsname -v crdb-$loc2 -e true

az network private-dns link vnet create -g $rg -n $loc3-DNSLink \
   -z $dnsname -v crdb-$loc3 -e true
```


- Create Public IPs for the all of the VM's.

```
az network public-ip create --resource-group $rg --location $loc1 --name crdb-$loc1-ip1 --sku standard
az network public-ip create --resource-group $rg --location $loc1 --name crdb-$loc1-ip2 --sku standard
az network public-ip create --resource-group $rg --location $loc1 --name crdb-$loc1-ip3 --sku standard
az network public-ip create --resource-group $rg --location $loc2 --name crdb-$loc2-ip1 --sku standard
az network public-ip create --resource-group $rg --location $loc2 --name crdb-$loc2-ip2 --sku standard
az network public-ip create --resource-group $rg --location $loc2 --name crdb-$loc2-ip3 --sku standard
az network public-ip create --resource-group $rg --location $loc3 --name crdb-$loc3-ip1 --sku standard
az network public-ip create --resource-group $rg --location $loc3 --name crdb-$loc3-ip2 --sku standard
az network public-ip create --resource-group $rg --location $loc3 --name crdb-$loc3-ip3 --sku standard
```

- Create the NSG for subnets created.

```
az network nsg create --resource-group $rg --location $loc1 --name crdb-$loc1-nsg
az network nsg create --resource-group $rg --location $loc2 --name crdb-$loc2-nsg
az network nsg create --resource-group $rg --location $loc3 --name crdb-$loc3-nsg
```

- Add a rule to each group to allow SSH access.

```
az network nsg rule create -g $rg --nsg-name crdb-$loc1-nsg -n NsgRuleSSH --priority 100 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
    --protocol Tcp --description "Allow SSH Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc2-nsg -n NsgRuleSSH --priority 100 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
    --protocol Tcp --description "Allow SSH Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc3-nsg -n NsgRuleSSH --priority 100 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
    --protocol Tcp --description "Allow SSH Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc1-nsg -n NsgRulek8sAPI --priority 200 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 6443 --access Allow \
    --protocol Tcp --description "Allow Kubernetes API Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc2-nsg -n NsgRulek8sAPI --priority 200 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 6443 --access Allow \
    --protocol Tcp --description "Allow Kubernetes API Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc3-nsg -n NsgRulek8sAPI --priority 200 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 6443 --access Allow \
    --protocol Tcp --description "Allow Kubernetes API Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc1-nsg -n NsgRuleNodePorts --priority 300 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 30000-32767 --access Allow \
    --protocol Tcp --description "Allow Kubernetes NodePort Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc2-nsg -n NsgRuleNodePorts --priority 300 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 30000-32767 --access Allow \
    --protocol Tcp --description "Allow Kubernetes NodePort Access to all VMS."

az network nsg rule create -g $rg --nsg-name crdb-$loc3-nsg -n NsgRuleNodePorts --priority 300 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 30000-32767 --access Allow \
    --protocol Tcp --description "Allow Kubernetes NodePort Access to all VMS."
```

- Create Network Interfaces for all of the required Virtual Machines.

```
az network nic create --resource-group $rg -l $loc1 --name crdb-$loc1-nic1 --vnet-name crdb-$loc1 --subnet crdb-$loc1-sub1 --network-security-group crdb-$loc1-nsg --public-ip-address crdb-$loc1-ip1
az network nic create --resource-group $rg -l $loc1 --name crdb-$loc1-nic2 --vnet-name crdb-$loc1 --subnet crdb-$loc1-sub1 --network-security-group crdb-$loc1-nsg --public-ip-address crdb-$loc1-ip2
az network nic create --resource-group $rg -l $loc1 --name crdb-$loc1-nic3 --vnet-name crdb-$loc1 --subnet crdb-$loc1-sub1 --network-security-group crdb-$loc1-nsg --public-ip-address crdb-$loc1-ip3
az network nic create --resource-group $rg -l $loc2 --name crdb-$loc2-nic1 --vnet-name crdb-$loc2 --subnet crdb-$loc2-sub1 --network-security-group crdb-$loc2-nsg --public-ip-address crdb-$loc2-ip1
az network nic create --resource-group $rg -l $loc2 --name crdb-$loc2-nic2 --vnet-name crdb-$loc2 --subnet crdb-$loc2-sub1 --network-security-group crdb-$loc2-nsg --public-ip-address crdb-$loc2-ip2
az network nic create --resource-group $rg -l $loc2 --name crdb-$loc2-nic3 --vnet-name crdb-$loc2 --subnet crdb-$loc2-sub1 --network-security-group crdb-$loc2-nsg --public-ip-address crdb-$loc2-ip3
az network nic create --resource-group $rg -l $loc3 --name crdb-$loc3-nic1 --vnet-name crdb-$loc3 --subnet crdb-$loc3-sub1 --network-security-group crdb-$loc3-nsg --public-ip-address crdb-$loc3-ip1
az network nic create --resource-group $rg -l $loc3 --name crdb-$loc3-nic2 --vnet-name crdb-$loc3 --subnet crdb-$loc3-sub1 --network-security-group crdb-$loc3-nsg --public-ip-address crdb-$loc3-ip2
az network nic create --resource-group $rg -l $loc3 --name crdb-$loc3-nic3 --vnet-name crdb-$loc3 --subnet crdb-$loc3-sub1 --network-security-group crdb-$loc3-nsg --public-ip-address crdb-$loc3-ip3
```
- Deploy all the required virtual machines. In this demo we will be using 3 nodes in each region.

```
cat << EOF > cloud-init.txt
#cloud-config
package_upgrade: true
packages:
  - curl
output: {all: '| tee -a /var/log/cloud-init-output.log'}
runcmd:
  - set -e
  - grep -v -G domain-name /etc/dhcp/dhclient.conf  > dhclient.tmp
  - echo "supersede domain-name \"$dnsname\";"    >> dhclient.tmp
  - echo "prepend domain-name-servers 168.63.129.16;" >> dhclient.tmp
  - sudo cp /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.old
  - sudo cp dhclient.tmp /etc/dhcp/dhclient.conf
  - sudo dhclient -v
EOF
```

### Region 1

```
az vm create \
  --resource-group $rg \
  --location $loc1 \
  --name crdb-$loc1-node1 \
  --image UbuntuLTS \
  --nics crdb-$loc1-nic1 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc1 \
  --name crdb-$loc1-node2 \
  --image UbuntuLTS \
  --nics crdb-$loc1-nic2 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc1 \
  --name crdb-$loc1-node3 \
  --image UbuntuLTS \
  --nics crdb-$loc1-nic3 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt
```
### Region 2

```
az vm create \
  --resource-group $rg \
  --location $loc2 \
  --name crdb-$loc2-node1 \
  --image UbuntuLTS \
  --nics crdb-$loc2-nic1 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc2 \
  --name crdb-$loc2-node2 \
  --image UbuntuLTS \
  --nics crdb-$loc2-nic2 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc2 \
  --name crdb-$loc2-node3 \
  --image UbuntuLTS \
  --nics crdb-$loc2-nic3 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt
```
### Region 3

```
az vm create \
  --resource-group $rg \
  --location $loc3 \
  --name crdb-$loc3-node1 \
  --image UbuntuLTS \
  --nics crdb-$loc3-nic1 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc3 \
  --name crdb-$loc3-node2 \
  --image UbuntuLTS \
  --nics crdb-$loc3-nic2 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

az vm create \
  --resource-group $rg \
  --location $loc3 \
  --name crdb-$loc3-node3 \
  --image UbuntuLTS \
  --nics crdb-$loc3-nic3 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt
```

- Deploy an internal Load Balancer for the virtual machines in Region 3

Create the Load Balancer and two Health Probes for the two services we are intending to load balance in Region 3.

```
az network lb create \
    --resource-group $rg \
    --name crdb-$loc3-lb \
    --location northeurope \
    --sku Standard \
    --vnet-name crdb-$loc3 \
    --subnet crdb-$loc3-sub1 \
    --frontend-ip-name crdb-$loc3-frontend \
    --backend-pool-name crdb-$loc3-backendpool

az network lb probe create \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb \
    --name healthprobe-sql \
    --protocol tcp \
    --port 26257

az network lb probe create \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb \
    --name healthprobe-http \
    --protocol tcp \
    --port 8080   
```
Create the load balancing rules for the two services. 

```
az network lb rule create \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb \
    --name crdb-$loc3-HTTPRule \
    --protocol tcp \
    --frontend-port 8080 \
    --backend-port 8080 \
    --frontend-ip-name crdb-$loc3-frontend \
    --backend-pool-name crdb-$loc3-backendpool \
    --probe-name healthprobe-http \
    --idle-timeout 15 \
    --enable-tcp-reset true

az network lb rule create \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb \
    --name crdb-$loc3-SQLRule \
    --protocol tcp \
    --frontend-port 26257 \
    --backend-port 26257 \
    --frontend-ip-name crdb-$loc3-frontend \
    --backend-pool-name crdb-$loc3-backendpool \
    --probe-name healthprobe-sql \
    --idle-timeout 15 \
    --enable-tcp-reset true
```

Add the three VM's in Region 3 to the backend pool.
```
az network nic ip-config address-pool add \
    --address-pool crdb-$loc3-backendpool \
    --ip-config-name ipconfig1 \
    --nic-name crdb-$loc3-nic1 \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb

az network nic ip-config address-pool add \
    --address-pool crdb-$loc3-backendpool \
    --ip-config-name ipconfig1 \
    --nic-name crdb-$loc3-nic2 \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb

az network nic ip-config address-pool add \
    --address-pool crdb-$loc3-backendpool \
    --ip-config-name ipconfig1 \
    --nic-name crdb-$loc3-nic3 \
    --resource-group $rg \
    --lb-name crdb-$loc3-lb
```

Create and Virtual Machine to run the MOVR application.

```
az network public-ip create --resource-group $rg --location $loc3 --name crdb-$loc3-ip4 --sku standard

az network nic create \
    --resource-group $rg \
    -l $loc3 \
    --name crdb-$loc3-nic4 \
    --vnet-name crdb-$loc3 --subnet crdb-$loc3-sub1 --network-security-group crdb-$loc3-nsg --public-ip-address crdb-$loc3-ip4

az vm create \
  --resource-group $rg \
  --location $loc3 \
  --name crdb-$loc3-node4 \
  --image UbuntuLTS \
  --nics crdb-$loc3-nic4 \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --custom-data cloud-init.txt
```


You now have all the required infrastructure to move to the next stage. [Deploying Kubernetes.](kubernetes-setup.md)

[Back](README.md)
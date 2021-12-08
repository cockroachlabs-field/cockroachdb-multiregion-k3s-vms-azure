# Virtual Machine Setup

The following steps need to be completed on each of the nodes which you wish to add to the cluster.

First step is to SSH to the node and the required folder structure.
```
LOC3NODE1=$(az vm show -d -g $rg  -n crdb-$loc3-node1 --query publicIps -o tsv)

ssh ubuntu@$LOC3NODE1
```
Once connected we need to create some folders and update `/etc/dhcp/dhclient.conf` with the correct DNS suffix so the node identifies it self with the correct DNS suffix so name resolution work as intended.
```
vim /etc/dhcp/dhclient.conf
```
Add the following line to the file.
```
supersede domain-name "private.cockroach.internal";
```
By adding this line to the file `/etc/dhcp/dhclient.conf` the host will now identify itself with the correct resolvable FQDN.
Now create the required folder structure. 
```
mkdir cockroach
cd cockroach
mkdir certs
exit
```
Now we need to transfer some files over to each nodes. This would be the required certificates to join the nodes to the cluster. We will also transfer a shell script that will start cockroach on each node.
```
scp startdb.sh ubuntu@4$LOC3NODE1:/home/ubuntu/cockroach
cd multiregion/certs
scp ca.crt client.root.crt client.root.key node.crt node.key ubuntu@4$LOC3NODE1:/home/ubuntu/cockroach/certs
```

Now all the files have been copied across to the node we can SSH in and install and run Cockroachdb. First we download the binary, extract and copy to our path.
```
curl https://binaries.cockroachdb.com/cockroach-v21.2.2.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.2.2.linux-amd64/cockroach /usr/local/bin/

cockroach --version
chmod 766 startdb.sh    
cd cockroach/certs
chmod 700 *
./startdb.sh
```
Repeat these steps on the other two nodes...
You will then be able to access the Admin UI via your browser. http://localhost:8080

```bash
kubectl port-forward cockroachdb-0 8080 --context $clus1 --namespace $loc1
```

In the UI you  should see all of of the nine nodes, six coming form Kubernetes and three from Virtual Machines.

[Back](README.md)


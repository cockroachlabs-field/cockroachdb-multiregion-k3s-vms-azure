# Virtual Machine Setup

The following steps need to be completed on each of the nodes which you wish to add to the cluster.

- First step is to SSH to the node and the required folder structure.
```
LOC3NODE1=$(az vm show -d -g $rg  -n crdb-$loc3-node1 --query publicIps -o tsv)

ssh ubuntu@$LOC3NODE1
```
- Now create the required folder structure. 
```
mkdir cockroach
cd cockroach
mkdir certs
mkdir my-safe-directory
exit
```
- Now we need to transfer some files over to each nodes. This would be the required certificates to join the nodes to the cluster. We will also transfer a shell script that will start cockroach on each node.
```
scp startdb.sh ubuntu@$LOC3NODE1:/home/ubuntu/cockroach
cd multiregion/certs
scp ca.crt client.root.crt client.root.key ubuntu@$LOC3NODE1:/home/ubuntu/cockroach/certs
cd ../my-safe-directory
scp ca.key ubuntu@$LOC3NODE1:/home/ubuntu/cockroach/my-safe-directory
```

Now all the files have been copied across to the node we can SSH in and install and run Cockroachdb. First we download the binary, extract and copy to our path.
```
ssh ubuntu@$LOC3NODE1

curl https://binaries.cockroachdb.com/cockroach-v21.2.3.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.2.3.linux-amd64/cockroach /usr/local/bin/

cockroach --version
cd cockroach
chmod 766 startdb.sh    
cd certs
chmod 700 *
./startdb.sh
```
Repeat these steps on the other two nodes...
```
LOC3NODE2=$(az vm show -d -g $rg  -n crdb-$loc3-node2 --query publicIps -o tsv)

ssh ubuntu@$LOC3NODE2
```
```
mkdir cockroach
cd cockroach
mkdir certs
mkdir my-safe-directory
exit
```

```
scp startdb.sh ubuntu@$LOC3NODE2:/home/ubuntu/cockroach
cd multiregion/certs
scp ca.crt client.root.crt client.root.key ubuntu@$LOC3NODE2:/home/ubuntu/cockroach/certs
cd ../my-safe-directory
scp ca.key ubuntu@$LOC3NODE2:/home/ubuntu/cockroach/my-safe-directory
```

Now all the files have been copied across to the node we can SSH in and install and run Cockroachdb. First we download the binary, extract and copy to our path.
```
ssh ubuntu@$LOC3NODE2
```

```
curl https://binaries.cockroachdb.com/cockroach-v21.2.3.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.2.3.linux-amd64/cockroach /usr/local/bin/

cockroach --version
cd cockroach
chmod 766 startdb.sh    
cd certs
chmod 700 *
cd ../my-safe-directory
chmod 700 *
cd ..
./startdb.sh
```

Node 3....
```
LOC3NODE3=$(az vm show -d -g $rg  -n crdb-$loc3-node3 --query publicIps -o tsv)

ssh ubuntu@$LOC3NODE3
```
```
mkdir cockroach
cd cockroach
mkdir certs
mkdir my-safe-directory
exit
```

```
scp startdb.sh ubuntu@$LOC3NODE3:/home/ubuntu/cockroach
cd multiregion/certs
scp ca.crt client.root.crt client.root.key ubuntu@$LOC3NODE3:/home/ubuntu/cockroach/certs
cd ../my-safe-directory
scp ca.key ubuntu@$LOC3NODE3:/home/ubuntu/cockroach/my-safe-directory
```

Now all the files have been copied across to the node we can SSH in and install and run Cockroachdb. First we download the binary, extract and copy to our path.
```
ssh ubuntu@$LOC3NODE3
```

```
curl https://binaries.cockroachdb.com/cockroach-v21.2.3.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.2.3.linux-amd64/cockroach /usr/local/bin/

cockroach --version
cd cockroach
chmod 766 startdb.sh    
cd certs
chmod 700 *
cd ../my-safe-directory
chmod 700 *
cd ..
./startdb.sh
```

You will then be able to access the Admin UI via your browser. http://localhost:8080

```bash
kubectl port-forward cockroachdb-0 8080 --context $clus1 --namespace $loc1
```

In the UI you  should see all of of the nine nodes, six coming form Kubernetes and three from Virtual Machines.


[Back](README.md)


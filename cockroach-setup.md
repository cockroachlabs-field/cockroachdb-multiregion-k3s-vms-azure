# Deploy CockroachDB to Kubernetes Clusters

Change directory to the 'multiregion' folder.

```bash
cd multiregion
```

Retrieve the kubectl "contexts" for your clusters:

```
kubectl config get-contexts
```

At the top of the setup.py script, fill in the contexts map with the zones of your clusters and their "context" names, this has been done in the files provided in this demo but is for the regions set out at the beginning. e.g.:
```
contexts = {
    'eastus': 'crdb-k3s-eastus',
    'westus': 'crdb-k3s-westus',
}
```
In the setup.py script, fill in the regions map with the zones and corresponding regions of your clusters, for example:
```
regions = {
    'eastus': 'eastus',
    'westus': 'westus',
}
```
Setting regions is optional, but recommended, because it improves CockroachDB's ability to diversify data placement if you use more than one zone in the same region. If you aren't specifying regions, just leave the map empty.

- Run the `setup.py` script: 

```bash
python setup.py
```

- For each region, first back up the existing ConfigMap:  

```bash
kubectl -n kube-system get configmap coredns -o yaml > <configmap-backup-name>
```

In this demo I have used `eastus` and `westus` for my Kubernetes regions and `northeurope` as my virtual machines region. If you are using the same then you will be able to use the two configmaps below. If you are using other regions and IP addressing then you can use them as examples but you will need to edit the contents to reflect the regions you are using. Here is a snippet below that show where you need to modify.

```
    westus.svc.cluster.local:53 {       # <---- Modify
        log
        errors
        ready
        cache 10
        forward . 10.2.1.4 10.2.1.5 10.2.1.6 {      # <---- Modify
        }
    }
    private.cockroach.internal:53 {       # <---- Modify
        log
        errors
        ready
        cache 10
        forward . 168.63.129.16:53 {      # <---- Modify
        }
    }
```

Then apply the new ConfigMap:

```bash
kubectl replace -f eastus.yaml --context crdb-k3s-eastus --force
kubectl replace -f westus.yaml --context crdb-k3s-westus --force
```

- For each region, check that your CoreDNS settings were applied: 

```bash
kubectl get -n kube-system cm/coredns --export -o yaml --context <cluster-context>
```

- Confirm that the CockroachDB pods in each cluster say `1/1` in the `READY` column - This could take a couple of minutes to propagate, indicating that they've successfully joined the cluster:    

```bash
kubectl get pods --selector app=cockroachdb --all-namespaces --context $clus1
```

> `NAMESPACE NAME READY STATUS RESTARTS AGE
us-east cockroachdb-0 1/1 Running 0 14m
us-east cockroachdb-1 1/1 Running 0 14m
us-east cockroachdb-2 1/1 Running 0 14m`


```bash
kubectl get pods --selector app=cockroachdb --all-namespaces --context $clus2
```

> `NAMESPACE NAME READY STATUS RESTARTS AGE
us-west cockroachdb-0 1/1 Running 0 14m
us-west cockroachdb-1 1/1 Running 0 14m
us-west cockroachdb-2 1/1 Running 0 14m`


- Create secure clients

```bash
kubectl create -f client-secure.yaml --namespace $loc1
```

```bash
kubectl exec -it cockroachdb-client-secure -n $loc1 -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

- Create a user and make admin.

```
CREATE USER <username> WITH PASSWORD 'cockroach';
GRANT admin TO <username>;
\q
```
Now you are ready to move to the next step. [Virtual Machine Setup](vm-setup.md)

[Back](README.md)
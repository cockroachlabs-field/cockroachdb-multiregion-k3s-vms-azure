# Deploy CockroachDB to Kubernetes Clusters

1. Change directory to the 'multiregion' folder.

```bash
cd multiregion
```

1. Run the `setup.py` script: 

```bash
python setup.py
```

1. For each region, first back up the existing ConfigMap:  

```bash
kubectl -n kube-system get configmap coredns -o yaml > <configmap-backup-name>
```

Then apply the new ConfigMap:

```bash
kubectl replace -f eastus.yaml --context crdb-k3s-eastus --force
kubectl replace -f westus.yaml --context crdb-k3s-westus --force
```

4. For each region, check that your CoreDNS settings were applied: 

```bash
kubectl get -n kube-system cm/coredns --export -o yaml --context <cluster-context>
```

8. Confirm that the CockroachDB pods in each cluster say `1/1` in the `READY` column - This could take a couple of minutes to propagate, indicating that they've successfully joined the cluster:    

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


9. Create secure clients

```bash
kubectl create -f client-secure.yaml --namespace $loc1
```

```bash
kubectl exec -it cockroachdb-client-secure -n $loc1 -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

10. Create a user and make admin.

```
CREATE USER <username>;
GRANT admin TO <username>;
```
Now you are ready to move to the next step. [Virtual Machine Setup](vm-setup.md)
[Back](README.md)
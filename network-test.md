Set Context for $clus1
```
kubectl config use-context $clus1
```
Create a test pod to ping
```
kubectl run network-test --image=alpine --restart=Never -- sleep 999999
```

Get Ip addresss of pod to ping
```
kubectl describe pods
```

Switch to $clus2 context
```
kubectl config use-context $clus2
```
Create a pod and ping the test pod
```
kubectl run -it network-test --image=alpine --restart=Never -- ping $podip
```
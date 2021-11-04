Set Context for k3s-cl1
```
kubectl config use-context k3s-cl1
```
Create a test pod to ping
```
kubectl run network-test --image=alpine --restart=Never -- sleep 999999
```

Get Ip addresss of pod to ping
```
kubectl describe pods
```

Switch to k3s-cl2 context
```
kubectl config use-context k3s-cl2
```
Create a pod and ping the test pod
```
kubectl run -it network-test --image=alpine --restart=Never -- ping $podip
```
10.10.0.41
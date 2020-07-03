This program is using GO to call stress linux command on targeted PODs. It will run 5 iterations of `stress` command with following parameters:

- CPU forks equal to number of cores.
- Memory forks will be computed to allocate whole memory.

For details what `stress` does under the hood see [manual](https://linux.die.net/man/1/stress).

## to start apply for nodes

```
kubectl apply -f stress/node.yaml
```

Wait at least 30 seconds and check for `CrashLooping` pods and `NotReady` nodes.

```
kubectl get pods -n kube-system
kubectl get nodes
```

```
kubectl delete -f stress/node.yaml
```

Usually pods like `kube-proxy`, `ingress-controller` are crashlooping. If kubelet or docker was affected by stress test then node will become `NotReady`.

## Stress test whole cluster

can start stress check on the whole cluster (including a master node).

```
kubectl apply -f stress/cluster.yaml
```

This execution will generate stress on cluster level
```
kubectl delete -f stress/node.yaml
```

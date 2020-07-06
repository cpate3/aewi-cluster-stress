# WI EKS cluster service stack validation Plan

Production Ready Checklist for Clusters (Build Pipeline / Deployment pipeline / Image Registry /Monitoring Infrastructure / Shared Storage / Secrets management )

### Interacting with k8s checks 

API (Talk to Kubernetes API : https://kubernetes.io/docs/reference/#api-client-libraries)
```
kubectl config current-context
kubectl cluster-info
```

Confirm nodes (master/worker nodes:
```
kubectl get nodes -o wide
```
Export the Worker Role Name for use
```
aws sts get-caller-identity
python3 api_checks.py   #kubernetes API checks python code
```

###  access control checks 

Authentication : user account / namespaces / Service accounts / Group accounts 
```
kubectl get ns & kubectl get role -n kube-system
kubectl get serviceaccount -n kube-system
```

Authorization : RBAC (roles with access to specific Kubernetes APIs )
```
kubectl get role --all-namespaces
kubectl get rolebinding --all-namespaces
kubectl get clusterroles
kubectl get clusterrolebinding
```

### K8s resources checks (Make sure Pods are ephemeral)

#Resources (pods, sidecars, controllers)
```
kubectl get pods --all-namespaces
kubectl -n istio-system get configmap istio-sidecar-injector
kubectl get crd
kubectl cluster-info dump  
python3 k8s-objects-checks.py    # Kubernetes API python code
```

### Configurations and secrets checks
```
kubectl get configmap 
kubectl describe configmap  cluster-infra-config
kubectl describe configmap cluster-map-config
kubectl get secret
kubectl describe secret default-token-jb2r9
```

### Control plane VPC subnets traffic checks (private hosted zone / public hosted zone / DNS forwarding - external/internal DNS)
```
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
kubectl get ep kube-dns --namespace=kube-system 

for name in $(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o name); do kubectl logs --timestamps $name -n kube-system && echo "NEXT - $name"; done
for ip in $(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o jsonpath='{.items[*].status.podIP}'); do kubectl exec -it coredns-59dfd6b59f-8rlbl --namespace=kube-system -- dig nikecloud.com @$ip && echo "NEXT"; done
```

### Control plane cluster IAM role checks
```
aws sts get-caller-identity
kubectl cluster-info dump | grep role
```

### Security groups service external ports traffic checks 
```
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\t"}}{{.name}}{{"\n"}}{{end}}{{end}}{{end}}' | sort 
```

### Logging aggregation checks 
```
kubectl logs -f external-dns-5b986969b5-2fxt9 -n kube-system
watch kubectl get pods -n kube-system
```

### Ingress / Egress traffic checks 

Istio gateway & services
```
GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
kubectl -n istio-system get svc
kubectl get endpoints -o wide

port forwarding traffic validation 
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 8080:3000
```

### Security checks 
```
kubectl get psp
kubectl describe psp eks.privileged
```

### Monitoring checks (Services / Infra Service Mesh)
```
kubectl get pods --all-namespaces | grep prometheus
kubectl get pods --all-namespaces | grep kiali
```
### Network policies checks (AWS CNI plugins)
```
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2
```
### Portability and scalability checks (Auto scaling / Auto healing)
```
kubectl get horizontalpodautoscalers --all-namespaces
kubectl describe horizontalpodautoscalers istio-ingressgateway  -n istio-system
```
### Performance stress tests checks
```
cat kube-stress/main.go
kubectl apply -f node.yaml
kubectl delete -f node.yaml
```
### ArgoCD (kubeflow) apps checks
```
kubectl -n argocd get applications
```
### Custom build controller checks (mapauthinit)
```
kubectl describe pod mapauthinit-controller-manager-5d8445bbdb-fk5p4 -n mapauthinit-system
```
### whats deploy on cluster checks
```
kubectl get deploy --all-namespaces
kubectl get daemonsets --all-namespaces
kubectl get replicasets --all-namespaces
```
### Open issues checks
```
kubectl get events --sort-by=.metadata.creationTimestamp --all-namespaces
kubectl logs metacontroller-0 -n kube-system
kubectl get jobs --all-namespaces
```

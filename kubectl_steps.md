################################################################
WI EKS cluster service stack validation Plan
################################################################
Production Ready Checklist for Clusters (Build Pipeline / Deployment pipeline / Image Registry /Monitoring Infrastructure / Shared Storage / Secrets management )

1 > Interacting with k8s checks 

API (Talk to Kubernetes API : https://kubernetes.io/docs/reference/#api-client-libraries)
kubectl config current-context
kubectl cluster-info

# Confirm nodes (master/worker nodes:
kubectl get nodes 

# Export the Worker Role Name for use
aws sts get-caller-identity
STACK_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo $STACK_NAME
echo $ROLE_NAME
#echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

2>  access control checks 

Authentication : user account / namespaces / Service accounts / Group accounts 
kubectl get ns & kubectl get role -n kube-system
kubectl get serviceaccount -n kube-system

Authorization : RBAC (roles with access to specific Kubernetes APIs )


3 > K8s resources checks (Make sure Pods are ephemeral)

Resources (pods, sidecars, controllers)
kubectl get pods --all-namespaces
kubectl -n istio-system get configmap istio-sidecar-injector
kubectl get crd
kubectl cluster-info dump  

4 > Configurations and secrets checks

kubectl get configmap 
kubectl describe configmap  cluster-infra-config
kubectl describe configmap cluster-map-config
kubectl get secret
kubectl describe secret default-token-jb2r9


5 > Control plane VPC subnets traffic checks (private hosted zone / public hosted zone / DNS forwarding - external/internal DNS)
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
kubectl get ep kube-dns --namespace=kube-system 

for name in $(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o name); do kubectl logs --timestamps $name -n kube-system && echo "NEXT - $name"; done
for ip in $(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o jsonpath='{.items[*].status.podIP}'); do kubectl exec -it coredns-59dfd6b59f-8rlbl --namespace=kube-system -- dig nikecloud.com @$ip && echo "NEXT"; done

6 > Control plane cluster IAM role checks
k get role --all-namespaces
k get rolebinding --all-namespaces
k get clusterrole
k get clusterrolebinding

7 > Security groups service external ports traffic checks 
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\t"}}{{.name}}{{"\n"}}{{end}}{{end}}{{end}}' | sort 

8 > Logging aggregation checks 
k logs -f external-dns-5b986969b5-2fxt9 -n kube-system
watch kubectl get pods -n kube-system

9 > Ingress / Egress traffic checks 

# Istio gateway & services
GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
kubectl -n istio-system get svc
k get endpoints -o wide

# port forwarding traffic validation 
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 8080:3000


10 > Security checks 
k get psp
kubectl describe psp eks.privileged

11 > Monitoring checks (Services / Infra Service Mesh)
k get pods --all-namespaces | grep prometheus
k get pods --all-namespaces | grep kiali


12 > Network policies checks (AWS CNI plugins)
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2

13 > portability and scalability checks (Auto scaling / Auto healing)
k get horizontalpodautoscalers --all-namespaces
k describe horizontalpodautoscalers istio-ingressgateway  -n istio-system

14 > performance stress tests checks
cat kube-stress/main.go
kubectl apply -f node.yaml
kubectl delete -f node.yaml

15 > ArgoCD (kubeflow) apps checks
kubectl -n kubeflow get applications

16 > Custom build controller checks (mapauthinit)
k describe pod mapauthinit-controller-manager-5d8445bbdb-fk5p4 -n mapauthinit-system

17 > whats deploy on cluster checks
kubectl get deploy --all-namespaces
kubectl get replicasets --all-namespaces
kubectl get daemonsets --all-namespaces

18 > Open issues checks
kubectl get events --sort-by=.metadata.creationTimestamp --all-namespaces
k logs metacontroller-0 -n kube-system
k get jobs --all-namespaces